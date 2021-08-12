# frozen_string_literal: true

require 'rails_helper'
require 'service/no_content_result'
require 'service/ok_result'
require 'service/not_found_result'

RSpec.describe InventoryListItemsController::DestroyService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, list_item.id).perform }

    let(:user) { create(:user) }
    let(:game) { create(:game, user: user) }

    let!(:aggregate_list) { create(:aggregate_inventory_list, game: game) }
    let!(:inventory_list) { create(:inventory_list, game: game, aggregate_list: aggregate_list) }

    context 'when all goes well' do
      context 'when there is no matching item on another list' do
        let!(:list_item) { create(:inventory_list_item, list: inventory_list) }

        before do
          aggregate_list.add_item_from_child_list(list_item)
        end

        it 'destroys the list item and aggregate list item' do
          expect { perform }
            .to change(game.inventory_list_items, :count).from(2).to(0)
        end

        it 'returns a Service::NoContentResult' do
          expect(perform).to be_a(Service::NoContentResult)
        end

        it "doesn't return any data", :aggregate_failures do
          expect(perform.resource).to be_blank
          expect(perform.errors).to be_blank
        end
      end

      context 'when there is a matching item on another list' do
        let!(:list_item)  { create(:inventory_list_item, list: inventory_list) }
        let(:other_list)  { create(:inventory_list, game: game) }
        let!(:other_item) { create(:inventory_list_item, description: list_item.description, list: other_list) }

        before do
          aggregate_list.add_item_from_child_list(list_item)
          aggregate_list.add_item_from_child_list(other_item)
        end

        it 'destroys the list item and aggregate list item' do
          expect { perform }
            .to change(game.inventory_list_items, :count).from(3).to(2)
        end

        it 'returns a Service::OKResult' do
          expect(perform).to be_a(Service::OKResult)
        end

        it 'returns the aggregate list item', :aggregate_failures do
          expect(perform.resource).to eq aggregate_list.list_items.first
        end
      end
    end

    context 'when the list item is not found' do
      let(:list_item) { double(id: 4568) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't set a resource or errors array", :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end
  end
end
