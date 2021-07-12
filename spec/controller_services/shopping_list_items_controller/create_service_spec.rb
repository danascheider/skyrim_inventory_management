# frozen_string_literal: true

require 'rails_helper'
require 'service/created_result'
require 'service/not_found_result'
require 'service/unprocessable_entity_result'
require 'service/method_not_allowed_result'
require 'service/ok_result'

RSpec.describe ShoppingListItemsController::CreateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, shopping_list.id, params).perform }

    let(:user) { create(:user) }

    context 'when all goes well' do
      let!(:aggregate_list) { create(:aggregate_shopping_list, user: user) }
      let!(:shopping_list) { create(:shopping_list, user: user, aggregate_list: aggregate_list) }
      let(:params) { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      before do
        allow(user.shopping_lists).to receive(:find).and_return(shopping_list)
        allow(shopping_list).to receive(:aggregate_list).and_return(aggregate_list)
      end

      context 'when there is no matching item on the regular list' do
        before do
          allow(aggregate_list).to receive(:add_item_from_child_list)
        end

        it 'adds a list item to the given list' do
          expect { perform }.to change(shopping_list.list_items, :count).from(0).to(1)
        end

        it 'assigns the correct values' do
          params_with_string_keys = {}
          params.each { |key, value| params_with_string_keys[key.to_s] = value }

          perform
          expect(shopping_list.list_items.last.attributes).to include(**params_with_string_keys)
        end

        it 'updates the aggregate list' do
          perform
          expect(aggregate_list).to have_received(:add_item_from_child_list).with(shopping_list.list_items.last)
        end

        it 'returns a Service::CreatedResult' do
          expect(perform).to be_a(Service::CreatedResult)
        end

        it 'returns both the created list item and aggregate list item' do
          expect(perform.resource).to eq([aggregate_list.list_items.last, shopping_list.list_items.last])
        end
      end

      context 'when there is a matching item on the regular list' do
        before do
          existing_item = create(:shopping_list_item, list: shopping_list, description: 'Necklace', quantity: 2, notes: 'to enchant')
          aggregate_list.add_item_from_child_list(existing_item)
          allow(aggregate_list).to receive(:update_item_from_child_list)
        end

        it "doesn't create a new item on the regular list" do
          expect { perform }.not_to change(shopping_list.list_items, :count)
        end

        it "doesn't create a new item on the aggregate list" do
          expect { perform }.not_to change(aggregate_list.list_items, :count)
        end

        it 'updates the aggregate list correctly' do
          perform
          expect(aggregate_list).to have_received(:update_item_from_child_list).with('Necklace', 2, nil, 'Hello world')
        end
      end
    end

    context 'when the list does not exist' do
      let(:shopping_list) { double("list that doesn't exist", id: 348) }
      let(:params) { { 'description' => 'Necklace', 'quantity' => 2, 'notes' => 'Hello world' } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end
    end

    context 'when the list does not belong to the user' do
      let!(:shopping_list) { create(:shopping_list) }
      let(:params) { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end
    end

    context 'when there is a duplicate description' do
      let!(:aggregate_list) { create(:aggregate_shopping_list, user: user) }
      let!(:shopping_list) { create(:shopping_list, user: user, aggregate_list: aggregate_list) }
      let(:params) { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      before do
        shopping_list.list_items.create!(description: 'Necklace', quantity: 1, notes: 'To enchant')
        aggregate_list.add_item_from_child_list(shopping_list.list_items.last)
      end

      it 'combines the item with an existing one' do
        expect { perform }.not_to change(shopping_list.list_items, :count)
      end

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the list items' do
        expect(perform.resource).to eq([aggregate_list.list_items.last, shopping_list.list_items.last])
      end
    end

    context 'when the params are invalid' do
      let!(:shopping_list) { create(:shopping_list, user: user) }
      let(:params) { { description: 'Necklace', quantity: -1, notes: 'invalid quantity' } }

      it 'returns a Service::UnprocessableEntityResult' do
        expect(perform).to be_a(Service::UnprocessableEntityResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Quantity must be greater than 0'])
      end
    end

    context 'when the list is an aggregate list' do
      let!(:shopping_list) { create(:aggregate_shopping_list, user: user) }
      let(:params) { { description: 'Necklace', quantity: 1, notes: 'this should not work' } }

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a(Service::MethodNotAllowedResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Cannot manually manage items on an aggregate shopping list'])
      end
    end
  end
end
