# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'
require 'service/not_found_result'

RSpec.describe InventoryListItemsController::UpdateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, list_item.id, params).perform }

    let(:user)            { create(:user) }
    let(:game)            { create(:game, user: user) }
    let!(:aggregate_list) { create(:aggregate_inventory_list, game: game) }
    let!(:inventory_list) { create(:inventory_list, game: game, aggregate_list: aggregate_list) }

    context 'when all goes well' do
      context 'when there is no matching item on another list' do
        let!(:list_item)          { create(:inventory_list_item, list: inventory_list, description: 'Dwarven metal ingot', quantity: 2) }
        let(:aggregate_list_item) { aggregate_list.list_items.first }
        let(:params)              { { quantity: 9, notes: 'To make bolts with' } }

        before do
          aggregate_list.add_item_from_child_list(list_item)
        end

        it 'updates the list item', :aggregate_failures do
          perform
          expect(list_item.reload.quantity).to eq 9
          expect(list_item.notes).to eq 'To make bolts with'
        end

        it 'updates the aggregate list item' do
          perform
          expect(aggregate_list_item.quantity).to eq 9
          expect(aggregate_list_item.notes).to eq 'To make bolts with'
        end

        it 'returns a Service::OKResult' do
          expect(perform).to be_a(Service::OKResult)
        end

        it 'returns the list item and aggregate list item as the resource' do
          expect(perform.resource).to eq [aggregate_list_item, list_item.reload]
        end
      end

      context 'when there is a matching item on another list' do
        let!(:list_item)          { create(:inventory_list_item, list: inventory_list, quantity: 4) }
        let(:other_list)          { create(:inventory_list, game: game, aggregate_list: aggregate_list) }
        let!(:other_item)         { create(:inventory_list_item, description: list_item.description, list: other_list, quantity: 3) }
        let(:aggregate_list_item) { aggregate_list.list_items.first }

        before do
          aggregate_list.add_item_from_child_list(list_item)
          aggregate_list.add_item_from_child_list(other_item)
        end

        context 'when the unit weight is not changed' do
          let(:params) { { quantity: 12 } }

          it 'updates the list item' do
            perform
            expect(list_item.reload.quantity).to eq 12
          end

          it 'updates the aggregate list item' do
            perform
            expect(aggregate_list.reload.list_items.first.quantity).to eq 15
          end

          it 'returns a Service::OKResult' do
            expect(perform).to be_a(Service::OKResult)
          end

          it 'sets the resource to the aggregate list item and the regular list item' do
            expect(perform.resource).to eq [aggregate_list_item, list_item.reload]
          end
        end

        context 'when the unit weight is changed' do
          let(:params) { { quantity: 10, unit_weight: 2 } }

          it 'updates the list item', :aggregate_failures do
            perform
            expect(list_item.reload.quantity).to eq 10
            expect(list_item.unit_weight).to eq 2
          end

          it 'updates the aggregate list item', :aggregate_failures do
            perform
            expect(aggregate_list_item.quantity).to eq 13
            expect(aggregate_list_item.unit_weight).to eq 2
          end

          it 'updates only the unit weight of the other list item', :aggregate_failures do
            perform
            expect(other_item.reload.quantity).to eq 3
            expect(other_item.unit_weight).to eq 2
          end

          it 'returns a Service::OKResult' do
            expect(perform).to be_a(Service::OKResult)
          end

          it 'returns all the list items that were changed' do
            expect(perform.resource).to eq [aggregate_list_item, other_item.reload, list_item.reload]
          end
        end
      end
    end

    context "when the inventory list item doesn't exist" do
      let(:list_item) { double(id: 3_459_250) }
      let(:params)    { { quantity: 4 } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it 'leaves the resource and errors empty', :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end

    context "when the inventory list item doesn't belong to the given user" do
      let(:list_item) { create(:inventory_list_item) }
      let(:params)    { { notes: 'Hello world' } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it 'leaves the resource and errors empty', :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end
  end
end
