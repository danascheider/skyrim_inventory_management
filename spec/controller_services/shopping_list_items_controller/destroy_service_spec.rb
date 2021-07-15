# frozen_string_literal: true

require 'rails_helper'
require 'service/no_content_result'
require 'service/ok_result'
require 'service/not_found_result'
require 'service/method_not_allowed_result'
require 'service/internal_server_error_result'

RSpec.describe ShoppingListItemsController::DestroyService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, list_item.id).perform }

    let(:user) { create(:user) }
    let!(:aggregate_list) { create(:aggregate_shopping_list, user: user) }
    let!(:shopping_list) { create(:shopping_list, user: user, aggregate_list: aggregate_list) }

    context 'when all goes well' do
      let(:list_item) { create(:shopping_list_item, list: shopping_list, notes: 'some notes') }

      before do
        aggregate_list.add_item_from_child_list(list_item)
      end

      context 'when the quantity on the aggregate list equals the quantity on the regular list' do
        it 'destroys the list item' do
          perform
          expect { ShoppingListItem.find(list_item.id) }.to raise_error ActiveRecord::RecordNotFound
        end

        it 'destroys the item on the aggregate list' do
          expect { perform }.to change(aggregate_list.list_items, :count).from(1).to(0)
        end

        it 'returns a Service::NoContentResult' do
          expect(perform).to be_a Service::NoContentResult
        end

        it 'does not return data' do
          expect(perform.resource).to be nil
        end

        it 'sets the updated_at timestamp on the shopping list', do
          t = Time.now + 3.days
          Timecop.freeze(t) do
            perform
            # use `be_within` even though the time will be set to the time Timecop
            # has frozen because Rails (Postgres?) sets the last three digits of
            # the timestamp to 0, which was breaking stuff in CI (but somehow not
            # in dev).
            expect(shopping_list.reload.updated_at).to be_within(0.005.seconds).of(t)
          end
        end
      end

      context 'when the quantity on the aggregate list exceeds the quantity on the regular list' do
        let(:second_list) { create(:shopping_list, user: user, aggregate_list: aggregate_list) }
        let(:second_list_item) do
          create(:shopping_list_item,
                  list: second_list,
                  description: list_item.description.upcase, # make sure comparison is case insensitive
                  quantity: 2,
                  notes: 'some other notes'
                )
        end

        before do
          aggregate_list.add_item_from_child_list(second_list_item)
        end

        it 'destroys the list item' do
          perform
          expect { ShoppingListItem.find(list_item.id) }.to raise_error ActiveRecord::RecordNotFound
        end
        
        it 'changes the quantity of the aggregate list item' do
          perform
          expect(aggregate_list.list_items.first.quantity).to eq 2
        end

        it 'changes the notes of the aggregate list item', :aggregate_failures do
          perform
          expect(aggregate_list.list_items.first.notes).to match /some other notes/
          expect(aggregate_list.list_items.first.notes).not_to match /some notes/
        end

        it 'sets the updated_at timestamp on the shopping list' do
          t = Time.now + 3.days
          Timecop.freeze(t) do
            perform
            # use `be_within` even though the time will be set to the time Timecop
            # has frozen because Rails (Postgres?) sets the last three digits of
            # the timestamp to 0, which was breaking stuff in CI (but somehow not
            # in dev).
            expect(shopping_list.reload.updated_at).to be_within(0.05.seconds).of(t)
          end
        end

        it 'returns a Service::OKResult' do
          expect(perform).to be_a Service::OKResult
        end

        it 'returns the updated aggregate list item' do
          expect(perform.resource).to eq aggregate_list.list_items.first
        end
      end
    end

    context "when the specified list item doesn't exist" do
      let(:list_item) { double("this item doesn't exist", id: 389) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any error messages" do
        expect(perform.errors).to eq []
      end
    end

    context "when the specified list item doesn't belong to the authenticated user" do
      let(:list_item) { create(:shopping_list_item) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a Service::NotFoundResult
      end

      it "doesn't return any error messages" do
        expect(perform.errors).to eq []
      end
    end

    context 'when the specified list item is on an aggregate list' do
      let(:list_item) { create(:shopping_list_item, list: aggregate_list) }

      it "doesn't destroy the list item" do
        perform
        expect(ShoppingListItem.find(list_item.id)).to be_a ShoppingListItem
      end

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a Service::MethodNotAllowedResult
      end

      it 'includes a helpful error message' do
        expect(perform.errors).to eq ['Cannot manually delete list item from aggregate shopping list']
      end
    end

    context 'when something unexpected goes wrong' do
      let(:list_item) { create(:shopping_list_item, list: shopping_list) }

      before do
        allow_any_instance_of(ShoppingListItem).to receive(:destroy!).and_raise(StandardError, 'Something went horribly wrong')
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
