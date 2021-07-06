# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'
require 'service/no_content_result'
require 'service/not_found_result'
require 'service/method_not_allowed_result'
require 'service/unprocessable_entity_result'

RSpec.describe ShoppingListItemsController::UpdateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, list_item.id, params).perform }

    let(:user) { create(:user) }
    let(:shopping_list) { user.shopping_lists.create! }
    
    context 'when all goes well' do
      let!(:list_item) { create(:shopping_list_item, list: shopping_list, quantity: 2) }
      let(:params) { { quantity: 3 } }
      let(:master_list) { user.master_shopping_list }
      let(:scope) { ShoppingListItem.belonging_to_user(user) }

      before do
        master_list.add_item_from_child_list(list_item)
      end

      it 'updates the shopping list item', :aggregate_failures do
        perform
        expect(list_item.reload.quantity).to eq 3
        expect(list_item.reload.notes).to be nil
      end

      it 'updates the item on the master list' do
        # Put the mocks in here because I don't want this much mocking in the other specs
        allow(ShoppingListItem).to receive(:belonging_to_user).with(user).and_return(scope)
        allow(scope).to receive(:find).and_return(list_item)
        allow(list_item).to receive(:list).and_return(shopping_list)
        allow(shopping_list).to receive(:master_list).and_return(master_list)
        allow(master_list).to receive(:update_item_from_child_list)
        perform
        expect(master_list).to have_received(:update_item_from_child_list).with(list_item.description, 1, nil, nil)
      end

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the resource to include both the regular and master list item' do
        expect(perform.resource).to eq([master_list.list_items.first, list_item])
      end

      it 'updates the updated_at timestamp on the list' do
        Timecop.freeze do
          perform
          expect(shopping_list.reload.updated_at).to eq Time.now.utc
        end
      end
    end

    context 'when the shopping list item is not found' do
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
      let(:list_item) { create(:shopping_list_item, list: shopping_list) }
      let(:params) { { description: 'This is not allowed' } }
      let(:master_list) { shopping_list.master_list }
      let(:scope) { ShoppingListItem.belonging_to_user(user) }

      it 'does not update the master list' do
        # Put the mocks in here because I don't want this much mocking in the other specs
        allow(ShoppingListItem).to receive(:belonging_to_user).with(user).and_return(scope)
        allow(scope).to receive(:find).and_return(list_item)
        allow(list_item).to receive(:list).and_return(shopping_list)
        allow(shopping_list).to receive(:master_list).and_return(master_list)
        allow(master_list).to receive(:update_item_from_child_list)
        perform
        expect(master_list).not_to have_received(:update_item_from_child_list).with(list_item.description, 1, nil, nil)
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

    context 'when the list item is on a master list' do
      let(:shopping_list) { create(:master_shopping_list, user: user) }
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
        expect(perform.errors).to eq ['Cannot manually update list items on a master shopping list']
      end
    end
  end
end
