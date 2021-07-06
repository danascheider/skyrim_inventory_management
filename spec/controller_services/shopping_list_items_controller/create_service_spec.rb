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
      let!(:master_list) { create(:master_shopping_list, user: user) }
      let!(:shopping_list) { create(:shopping_list, user: user, master_list: master_list) }
      let(:params) { { 'description' => 'Necklace', 'quantity' => 2, 'notes' => 'Hello world' } }

      before do
        allow(user.shopping_lists).to receive(:find).and_return(shopping_list)
        allow(shopping_list).to receive(:master_list).and_return(master_list)
        allow(master_list).to receive(:add_item_from_child_list)
      end

      it 'adds a list item to the given list', :aggregate_failures do
        expect { perform }.to change(shopping_list.list_items, :count).from(0).to(1)
      end

      it 'assigns the correct values' do
        perform
        expect(shopping_list.list_items.last.attributes).to include(**params)
      end

      it 'updates the master list', :aggregate_failures do
        perform
        expect(master_list).to have_received(:add_item_from_child_list)
      end

      it 'returns a Service::CreatedResult' do
        expect(perform).to be_a(Service::CreatedResult)
      end

      it 'returns both the created list item and master list item' do
        expect(perform.resource).to eq([master_list.list_items.last, shopping_list.list_items.last])
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
      let!(:master_list) { create(:master_shopping_list, user: user) }
      let!(:shopping_list) { create(:shopping_list, user: user, master_list: master_list) }
      let(:params) { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      before do
        shopping_list.list_items.create!(description: 'Necklace', quantity: 1, notes: 'To enchant')
        master_list.add_item_from_child_list(shopping_list.list_items.last)
      end

      it 'combines the item with an existing one' do
        expect { perform }.not_to change(shopping_list.list_items, :count)
      end

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the list items' do
        expect(perform.resource).to eq([master_list.list_items.last, shopping_list.list_items.last])
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

    context 'when the list is a master list' do
      let!(:shopping_list) { create(:master_shopping_list, user: user) }
      let(:params) { { description: 'Necklace', quantity: 1, notes: 'this should not work' } }

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a(Service::MethodNotAllowedResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Cannot manually manage items on a master shopping list'])
      end
    end
  end
end