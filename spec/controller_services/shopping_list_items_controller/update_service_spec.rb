# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'
require 'service/not_found_result'
require 'service/method_not_allowed_result'
require 'service/unprocessable_entity_result'
require 'service/internal_server_error_result'

RSpec.describe ShoppingListItemsController::UpdateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, list_item.id, params).perform }

    let(:user) { create(:user) }
    let!(:shopping_list) { game.shopping_lists.find_by(aggregate: false) }

    context 'when all goes well' do
      let(:game) { create(:game_with_shopping_lists, user: user) }
      let(:aggregate_list) { game.aggregate_shopping_list }
      let!(:list_item) { create(:shopping_list_item, list: shopping_list, quantity: 2) }
      let(:params) { { quantity: 3 } }
      let(:scope) { ShoppingListItem.belonging_to_user(user) }

      before do
        aggregate_list.add_item_from_child_list(list_item)
      end

      it 'updates the shopping list item', :aggregate_failures do
        perform
        expect(list_item.reload.quantity).to eq 3
        expect(list_item.reload.notes).to be nil
      end

      it 'updates the item on the aggregate list' do
        # Put the mocks in here because I don't want this much mocking in the other specs
        allow(ShoppingListItem).to receive(:belonging_to_user).with(user).and_return(scope)
        allow(scope).to receive(:find).and_return(list_item)
        allow(list_item).to receive(:list).and_return(shopping_list)
        allow(shopping_list).to receive(:aggregate_list).and_return(aggregate_list)
        allow(aggregate_list).to receive(:update_item_from_child_list)
        perform
        expect(aggregate_list).to have_received(:update_item_from_child_list).with(list_item.description, 1, nil, nil)
      end

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the resource to include both the regular and aggregate list item' do
        expect(perform.resource).to eq([aggregate_list.list_items.reload.first, list_item])
      end

      it 'updates the updated_at timestamp on the list' do
        t = Time.zone.now + 3.days
        Timecop.freeze(t) do
          perform
          # This is another case of a rounding error in the CI environment. The server where
          # GitHub Actions run seems to truncate the last few digits of the timestamp, resulting
          # in things being not quite equal in that environment. Since it's not that important
          # that it be that exact, I'm just using the `be_within` matcher.
          expect(shopping_list.reload.updated_at).to be_within(0.005.seconds).of(t)
        end
      end
    end

    context 'when the shopping list item is not found' do
      let(:game) { create(:game_with_shopping_lists) }
      let(:list_item) { double("the item that doesn't exist", id: 838) }
      let(:params) { { quantity: 3 } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it 'sets the errors to empty' do
        expect(perform.errors).to eq []
      end
    end

    context 'when the shopping list item does not belong to the user' do
      let(:game) { create(:game_with_shopping_lists) }
      let(:list_item) { create(:shopping_list_item) }
      let(:params) { { quantity: 3 } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it 'sets the errors to empty' do
        expect(perform.errors).to eq []
      end
    end

    context 'when the params are invalid' do
      let!(:list_item) { create(:shopping_list_item, list: shopping_list) }
      let(:game) { create(:game_with_shopping_lists, user: user) }
      let(:params) { { description: 'This is not allowed' } }
      let(:aggregate_list) { shopping_list.aggregate_list }
      let(:scope) { ShoppingListItem.belonging_to_user(user) }

      it 'does not update the aggregate list' do
        # Put the mocks in here because I don't want this much mocking in the other specs
        allow(ShoppingListItem).to receive(:belonging_to_user).with(user).and_return(scope)
        allow(scope).to receive(:find).and_return(list_item)
        allow(list_item).to receive(:list).and_return(shopping_list)
        allow(shopping_list).to receive(:aggregate_list).and_return(aggregate_list)
        allow(aggregate_list).to receive(:update_item_from_child_list)
        perform
        expect(aggregate_list).not_to have_received(:update_item_from_child_list).with(list_item.description, 1, nil, nil)
      end

      it 'does not update the shopping list itself' do
        t = Time.zone.now + 3.days
        Timecop.freeze(t) do
          perform
          expect(shopping_list.reload.updated_at).not_to be_within(71.hours).of(t)
        end
      end

      it 'returns a Service::UnprocessableEntityResult' do
        expect(perform).to be_a Service::UnprocessableEntityResult
      end

      it 'returns the errors' do
        expect(perform.errors).to eq ['Description cannot be updated on an existing list item']
      end
    end

    context "when the shopping list item doesn't belong to the authenticated user" do
      let(:shopping_list) { create(:shopping_list) }
      let(:list_item) { create(:shopping_list_item, list: shopping_list) }
      let(:params) { { quantity: 4 } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a Service::NotFoundResult
      end

      it 'does not include any errors' do
        expect(perform.errors).to eq []
      end
    end

    context 'when the list item is on an aggregate list' do
      let(:game) { create(:game_with_shopping_lists, user: user) }
      let(:shopping_list) { game.aggregate_shopping_list }
      let(:list_item) { create(:shopping_list_item, list: shopping_list) }
      let(:params) { { quantity: 4 } }

      it 'does not update the item' do
        perform
        expect(list_item.quantity).to eq 1
      end

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a(Service::MethodNotAllowedResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq ['Cannot manually update list items on an aggregate shopping list']
      end
    end

    context 'when something unexpected goes wrong' do
      let(:game) { create(:game_with_shopping_lists, user: user) }
      let!(:list_item) { create(:shopping_list_item, list: shopping_list) }
      let(:shopping_list) { create(:shopping_list, game: game) }
      let(:params) { { quantity: 4 } }

      before do
        allow_any_instance_of(ShoppingListItem).to receive(:save!).and_raise(StandardError, 'Something went horribly wrong')
      end

      it 'returns a Service::InternalServerErrorResult' do
        expect(perform).to be_a(Service::InternalServerErrorResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Something went horribly wrong'])
      end
    end
  end
end
