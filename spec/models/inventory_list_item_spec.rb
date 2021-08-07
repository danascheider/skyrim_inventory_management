# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InventoryListItem, type: :model do
  let!(:game) { create(:game) }

  describe 'delegation' do
    let(:inventory_list) { create(:inventory_list, game: game) }
    let(:list_item)      { create(:inventory_list_item, list: inventory_list) }

    before do
      create(:aggregate_inventory_list, game: game)
    end

    describe '#game' do
      it 'returns the game its InventoryList belongs to' do
        expect(list_item.game).to eq(game)
      end
    end

    describe '#user' do
      it 'returns the user its game belongs to' do
        expect(list_item.user).to eq(game.user)
      end
    end
  end
end
