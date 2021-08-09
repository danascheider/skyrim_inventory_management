# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'

RSpec.describe InventoryListsController::UpdateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, inventory_list.id, params).perform }

    let!(:aggregate_list) { create(:aggregate_inventory_list, game: game) }
    let(:user)            { create(:user) }
    let(:game)            { create(:game, user: user) }

    context 'when all goes well' do
      let(:inventory_list) { create(:inventory_list, game: game, aggregate_list: aggregate_list) }
      let(:params)         { { title: 'My New Title' } }

      it 'updates the inventory list' do
        perform
        expect(inventory_list.reload.title).to eq 'My New Title'
      end

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the resource to the updated inventory list' do
        expect(perform.resource).to eq inventory_list
      end

      it 'updates the game' do
        t = Time.zone.now + 3.days
        Timecop.freeze(t) do
          perform
          expect(game.reload.updated_at).to be_within(0.005.seconds).of(t)
        end
      end
    end
  end
end
