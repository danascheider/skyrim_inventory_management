# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'
require 'service/not_found_result'
require 'service/internal_server_error_result'

RSpec.describe InventoryListsController::IndexService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, game.id).perform }

    let(:user) { create(:user) }

    context 'when there are no inventory lists for that game' do
      let(:game) { create(:game, user:) }

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'returns the empty list' do
        expect(perform.resource).to eq []
      end
    end

    context 'when there are inventory lists for that game' do
      let(:game) { create(:game_with_inventory_lists, user:) }

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'returns the inventory lists' do
        expect(perform.resource).to eq game.inventory_lists
      end
    end

    context 'when the game is not found' do
      let(:game) { double(id: 2389) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any error messages" do
        expect(perform.errors).to be_empty
      end
    end

    context "when the game doesn't belong to the user" do
      let(:game) { create(:game) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any error messages" do
        expect(perform.errors).to be_empty
      end
    end

    context 'when something unexpected goes wrong' do
      let(:game) { create(:game, user:) }

      before do
        allow(user.games).to receive(:find).and_raise(StandardError.new('Something went horribly wrong'))
      end

      it 'returns a Service::InternalServerErrorResult' do
        expect(perform).to be_a(Service::InternalServerErrorResult)
      end

      it 'returns an array with the error message' do
        expect(perform.errors).to eq ['Something went horribly wrong']
      end
    end
  end
end
