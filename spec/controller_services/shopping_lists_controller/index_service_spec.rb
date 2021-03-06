# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'
require 'service/not_found_result'

RSpec.describe ShoppingListsController::IndexService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, game_id).perform }

    let(:user) { create(:user) }

    context 'when the game is not found' do
      let(:game_id) { 455_315 }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any error messages" do
        expect(perform.errors).to be_empty
      end
    end

    context 'when the game does not belong to the user' do
      let(:game)    { create(:game) }
      let(:game_id) { game.id }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any error messages" do
        expect(perform.errors).to be_empty
      end
    end

    context 'when there are no shopping lists for that game' do
      let(:game) { create(:game, user:) }
      let(:game_id) { game.id }

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the resource to be an empty array' do
        expect(perform.resource).to eq []
      end
    end

    context 'when there are shopping lists for that game' do
      let(:game) { create(:game_with_shopping_lists, user:) }
      let(:game_id) { game.id }

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it "sets the resource to the game's shopping lists" do
        expect(perform.resource).to eq game.shopping_lists.index_order
      end
    end

    context 'when something unexpected goes wrong' do
      let(:game) { create(:game, user:) }
      let(:game_id) { game.id }

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
