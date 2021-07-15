# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'

RSpec.describe ShoppingListsController::IndexService do
  describe '#perform' do
    subject(:perform) { described_class.new(game).perform }

    let(:game) { create(:game) }

    context 'when there are no shopping lists for that game' do
      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the resource to be an empty array' do
        expect(perform.resource).to eq []
      end
    end

    context 'when there are shopping lists for that game' do
      let!(:aggregate_list) { create(:aggregate_shopping_list, game: game) }
      let!(:lists) { create_list(:shopping_list_with_list_items, 2, game: game) }

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it "sets the resource to the game's shopping lists" do
        expect(perform.resource).to eq game.shopping_lists.index_order
      end
    end

    context 'when something unexpected goes wrong' do
      before do
        allow_any_instance_of(Game).to receive(:shopping_lists).and_raise(StandardError, 'Something went horribly wrong')
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
