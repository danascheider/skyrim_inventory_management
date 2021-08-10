# frozen_string_literal: true

require 'rails_helper'
require 'service/created_result'

RSpec.describe InventoryListItemsController::CreateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, inventory_list.id, params).perform }

    let(:user) { create(:user) }
    let(:game) { create(:game, user: user) }

    context 'when all goes well' do
      let!(:aggregate_list) { create(:aggregate_inventory_list, game: game) }
      let!(:inventory_list) { create(:inventory_list, game: game, aggregate_list: aggregate_list) }
      let(:params)          { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      context 'when there is no existing matching item on the same list' do
        context 'when there is no existing matching item on any list' do
          it 'creates a new item on the list' do
            expect { perform }
              .to change(inventory_list.list_items, :count).from(0).to(1)
          end

          it 'creates a new item on the aggregate list' do
            expect { perform }
              .to change(aggregate_list.list_items, :count).from(0).to(1)
          end

          it 'returns a Service::CreatedResult' do
            expect(perform).to be_a(Service::CreatedResult)
          end

          it 'sets the new and aggregate list items as the resource' do
            expect(perform.resource).to eq [aggregate_list.list_items.last, inventory_list.list_items.last]
          end
        end
      end
    end
  end
end
