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

  describe 'POST games/:game_id/inventory_lists' do
    subject(:create_inventory_list) { post "/games/#{game.id}/inventory_lists", params: { inventory_list: {} }.to_json, headers: headers }

    context 'when authenticated' do
      let!(:user) { create(:user) }
      let(:validation_data) do
        {
          'exp'   => (Time.zone.now + 1.year).to_i,
          'email' => user.email,
          'name'  => user.name,
        }
      end

      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when all goes well' do
        let(:game) { create(:game, user: user) }

        context 'when an aggregate list has also been created' do
          it 'creates a new inventory list' do
            expect { create_inventory_list }
              .to change(game.inventory_lists, :count).from(0).to(2) # because of the aggregate list
          end

          it 'returns the aggregate list as well as the new list' do
            create_inventory_list
            expect(response.body).to eq([game.aggregate_inventory_list, game.inventory_lists.last].to_json)
          end

          it 'returns status 201' do
            create_inventory_list
            expect(response.status).to eq 201
          end
        end

        context 'when only the new inventory list has been created' do
          let!(:aggregate_list) { create(:aggregate_inventory_list, game: game, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }

          it 'creates one list' do
            expect { create_inventory_list }
              .to change(game.inventory_lists, :count).from(1).to(2)
          end

          it 'returns only the newly created list' do
            create_inventory_list
            expect(response.body).to eq(game.inventory_lists.last.to_json)
          end
        end

        context 'when the request does not include a body' do
          subject(:create_inventory_list) { post "/games/#{game.id}/inventory_lists", headers: headers }

          before do
            # let's not have this request create an aggregate list too
            create(:aggregate_inventory_list, game: game)
          end

          it 'returns status 201' do
            create_inventory_list
            expect(response.status).to eq 201
          end

          it 'creates the inventory list with a default title' do
            create_inventory_list
            list_attributes = JSON.parse(response.body)
            expect(list_attributes['title']).to eq 'My List 1'
          end
        end
      end

      context 'when the game is not found' do
        let(:game) { double(id: 84_968_294) }

        it 'returns status 404' do
          create_inventory_list
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          create_inventory_list
          expect(response.body).to be_empty
        end
      end

      context "when the game doesn't belong to the authenticated user" do
        let(:game) { create(:game) }

        it 'returns status 404' do
          create_inventory_list
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          create_inventory_list
          expect(response.body).to be_empty
        end
      end

      context 'when the params are invalid' do
        subject(:create_inventory_list) { post "/games/#{game.id}/inventory_lists", params: { inventory_list: { title: existing_list.title } }.to_json, headers: headers }

        let(:game)          { create(:game, user: user) }
        let(:existing_list) { create(:inventory_list, game: game) }

        it 'returns status 422' do
          create_inventory_list
          expect(response.status).to eq 422
        end

        it 'returns the errors' do
          create_inventory_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Title must be unique per game'] })
        end
      end

      context 'when the client attempts to create an aggregate list' do
        subject(:create_inventory_list) { post "/games/#{game.id}/inventory_lists", params: { inventory_list: { aggregate: true } }.to_json, headers: headers }

        let(:game) { create(:game, user: user) }

        it "doesn't create a list" do
          expect { create_inventory_list }
            .not_to change(game.inventory_lists, :count)
        end

        it 'returns an error' do
          create_inventory_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          create_inventory_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually create an aggregate inventory list'] })
        end
      end
    end

    context 'when unauthenticated' do
      let(:game) { create(:game) }

      it 'returns 401' do
        create_inventory_list
        expect(response.status).to eq 401
      end
    end
  end
end
