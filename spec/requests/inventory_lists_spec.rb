# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'InventoryLists', type: :request do
  let(:headers) do
    {
      'Content-Type'  => 'application/json',
      'Authorization' => 'Bearer xxxxxxx',
    }
  end

  describe 'GET /games/:game_id/inventory_lists' do
    subject(:get_index) { get "/games/#{game.id}/inventory_lists", headers: headers }

    context 'when unauthenticated' do
      let(:game) { create(:game) }

      before do
        # create some data to not be returned
        create_list(:inventory_list, 3, game: game)
      end

      it 'returns 401' do
        get_index
        expect(response.status).to eq 401
      end

      it 'returns an error body indicating authorisation failed' do
        get_index
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Google OAuth token validation failed'] })
      end
    end

    context 'when authenticated' do
      let(:authenticated_user) { create(:user) }
      let(:validation_data) do
        {
          'exp'   => (Time.zone.now + 1.year).to_i,
          'email' => authenticated_user.email,
          'name'  => authenticated_user.name,
        }
      end

      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when the game is not found' do
        let(:game) { double(id: 491_349_759) }

        it 'returns status 404' do
          get_index
          expect(response.status).to eq 404
        end

        it 'returns no data' do
          get_index
          expect(response.body).to be_empty
        end
      end

      context "when the game doesn't belong to the authenticated user" do
        let(:game) { create(:game) }

        it 'returns status 404' do
          get_index
          expect(response.status).to eq 404
        end

        it 'returns no data' do
          get_index
          expect(response.body).to be_empty
        end
      end

      context 'when there are no inventory lists for that game' do
        let(:game) { create(:game, user: authenticated_user) }

        it 'returns status 200' do
          get_index
          expect(response.status).to eq 200
        end

        it 'returns an empty array' do
          get_index
          expect(JSON.parse(response.body)).to eq []
        end
      end

      context 'when there are inventory lists for that game' do
        let(:game) { create(:game_with_inventory_lists, user: authenticated_user) }

        it 'returns status 200' do
          get_index
          expect(response.status).to eq 200
        end

        it 'returns the inventory lists in index order' do
          get_index
          expect(response.body).to eq game.inventory_lists.index_order.to_json
        end
      end
    end
  end
end
