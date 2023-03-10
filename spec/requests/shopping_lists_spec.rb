# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ShoppingLists', type: :request do
  let(:headers) do
    {
      'Content-Type'  => 'application/json',
      'Authorization' => 'Bearer xxxxxxx',
    }
  end

  describe 'POST games/:game_id/shopping_lists' do
    subject(:create_shopping_list) { post "/games/#{game.id}/shopping_lists", params: { shopping_list: {} }.to_json, headers: }

    context 'when authenticated' do
      let!(:user) { create(:authenticated_user) }

      before do
        stub_successful_login
      end

      context 'when all goes well' do
        let(:game) { create(:game, user:) }

        context 'when an aggregate list has also been created' do
          it 'creates a new shopping list' do
            expect { create_shopping_list }
              .to change(game.shopping_lists, :count).from(0).to(2) # because of the aggregate list
          end

          it 'returns the aggregate list as well as the new list' do
            create_shopping_list
            expect(response.body).to eq([game.aggregate_shopping_list, game.shopping_lists.last].to_json)
          end

          it 'returns status 201' do
            create_shopping_list
            expect(response.status).to eq 201
          end
        end

        context 'when only the new shopping list has been created' do
          let!(:aggregate_list) { create(:aggregate_shopping_list, game:, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }

          it 'creates one list' do
            expect { create_shopping_list }
              .to change(game.shopping_lists, :count).from(1).to(2)
          end

          it 'returns only the newly created list' do
            create_shopping_list
            expect(response.body).to eq(game.shopping_lists.last.to_json)
          end
        end

        context 'when the request does not include a body' do
          subject(:create_shopping_list) { post "/games/#{game.id}/shopping_lists", headers: }

          before do
            # let's not have this request create an aggregate list too
            create(:aggregate_shopping_list, game:)
          end

          it 'returns status 201' do
            create_shopping_list
            expect(response.status).to eq 201
          end

          it 'creates the shopping list with a default title' do
            create_shopping_list
            list_attributes = JSON.parse(response.body)
            expect(list_attributes['title']).to eq 'My List 1'
          end
        end
      end

      context 'when the game is not found' do
        let(:game) { double(id: 84_968_294) }

        it 'returns status 404' do
          create_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          create_shopping_list
          expect(response.body).to be_empty
        end
      end

      context 'when the game belongs to another user' do
        let(:game) { create(:game) }

        it "doesn't create a shopping list" do
          expect { create_shopping_list }
            .not_to change(ShoppingList, :count)
        end

        it 'returns status 404' do
          create_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          create_shopping_list
          expect(response.body).to be_empty
        end
      end

      context 'when the params are invalid' do
        subject(:create_shopping_list) { post "/games/#{game.id}/shopping_lists", params: { shopping_list: { title: existing_list.title } }.to_json, headers: }

        let(:game) { create(:game, user:) }
        let(:existing_list) { create(:shopping_list, game:) }

        it 'returns status 422' do
          create_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns the errors' do
          create_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Title must be unique per game'] })
        end
      end

      context 'when the client attempts to create an aggregate list' do
        subject(:create_shopping_list) { post "/games/#{game.id}/shopping_lists", params: { shopping_list: { aggregate: true } }.to_json, headers: }

        let(:game) { create(:game, user:) }

        it "doesn't create a list" do
          expect { create_shopping_list }
            .not_to change(game.shopping_lists, :count)
        end

        it 'returns an error' do
          create_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          create_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually create an aggregate shopping list'] })
        end
      end
    end

    context 'when unauthenticated' do
      let!(:game) { create(:game) }

      before do
        stub_unsuccessful_login
      end

      it "doesn't create a shopping list" do
        expect { create_shopping_list }
          .not_to change(ShoppingList, :count)
      end

      it 'returns status 401' do
        create_shopping_list
        expect(response.status).to eq 401
      end

      it "doesn't return any data" do
        create_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Token validation response did not include a user'] })
      end
    end
  end

  describe 'PUT /shopping_lists/:id' do
    subject(:update_shopping_list) { put "/shopping_lists/#{list_id}", params: { shopping_list: { title: 'Severin Manor' } }.to_json, headers: }

    context 'when authenticated' do
      let!(:user) { create(:authenticated_user) }

      before do
        stub_successful_login
      end

      context 'when all goes well' do
        let!(:shopping_list) { create(:shopping_list, game:) }
        let(:game) { create(:game, user:) }
        let(:list_id) { shopping_list.id }

        it 'updates the title' do
          update_shopping_list
          expect(shopping_list.reload.title).to eq 'Severin Manor'
        end

        it 'returns the updated list' do
          update_shopping_list
          # This ugly hack is needed because if we don't parse the JSON, it'll make an error
          # if everything isn't in the exact same order, but if we just use shopping_list.attributes
          # it won't include the list_items. Ugly.
          expect(JSON.parse(response.body)).to eq(JSON.parse(shopping_list.reload.to_json))
        end

        it 'returns status 200' do
          update_shopping_list
          expect(response.status).to eq 200
        end
      end

      context 'when the params are invalid' do
        subject(:update_shopping_list) { put "/shopping_lists/#{list_id}", params: { shopping_list: { title: other_list.title } }.to_json, headers: }

        let!(:shopping_list) { create(:shopping_list, game:) }
        let(:game) { create(:game, user:) }
        let(:list_id) { shopping_list.id }
        let(:other_list) { create(:shopping_list, game:) }

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns the errors' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Title must be unique per game'] })
        end
      end

      context 'when the list does not exist' do
        let(:list_id) { 245_285 }

        it 'returns status 404' do
          update_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return data" do
          update_shopping_list
          expect(response.body).to be_blank
        end
      end

      context 'when the list belongs to another user' do
        let!(:shopping_list) { create(:shopping_list) }
        let(:list_id) { shopping_list.id }

        it "doesn't update the shopping list" do
          expect { update_shopping_list }
            .not_to change(shopping_list.reload, :title)
        end

        it 'returns status 404' do
          update_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return data" do
          update_shopping_list
          expect(response.body).to be_blank
        end
      end

      context 'when the client attempts to update an aggregate list' do
        subject(:update_shopping_list) { put "/shopping_lists/#{shopping_list.id}", params: { shopping_list: { title: 'Foo' } }.to_json, headers: }

        let!(:shopping_list) { create(:aggregate_shopping_list, game:) }
        let(:game) { create(:game, user:) }

        it "doesn't update the list" do
          update_shopping_list
          expect(shopping_list.reload.title).to eq 'All Items'
        end

        it 'returns status 405 (method not allowed)' do
          update_shopping_list
          expect(response.status).to eq 405
        end

        it 'returns a helpful error body' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually update an aggregate shopping list'] })
        end
      end

      context 'when the client attempts to change a regular list to an aggregate list' do
        subject(:update_shopping_list) { put "/shopping_lists/#{shopping_list.id}", params: { shopping_list: { aggregate: true } }.to_json, headers: }

        let!(:shopping_list) { create(:shopping_list, game:) }
        let(:game) { create(:game, user:) }

        it "doesn't update the list" do
          update_shopping_list
          expect(shopping_list.reload.aggregate).to eq false
        end

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot make a regular shopping list an aggregate list'] })
        end
      end

      context 'when something unexpected goes wrong' do
        subject(:update_shopping_list) { put "/shopping_lists/#{shopping_list.id}", params: { shopping_list: { title: 'Some New Title' } }.to_json, headers: }

        let!(:shopping_list) { create(:shopping_list, game:) }
        let(:game) { create(:game, user:) }

        before do
          allow_any_instance_of(User).to receive(:shopping_lists).and_raise(StandardError, 'Something went catastrophically wrong')
        end

        it 'returns status 500' do
          update_shopping_list
          expect(response.status).to eq 500
        end

        it 'returns the error in the body' do
          update_shopping_list
          expect(response.body).to eq({ errors: ['Something went catastrophically wrong'] }.to_json)
        end
      end
    end

    context 'when unauthenticated' do
      let!(:shopping_list) { create(:shopping_list) }
      let(:list_id) { shopping_list.id }

      before do
        stub_unsuccessful_login
      end

      it "doesn't update the shopping list" do
        expect { update_shopping_list }
          .not_to change(shopping_list.reload, :title)
      end

      it 'returns status 401' do
        update_shopping_list
        expect(response.status).to eq 401
      end

      it "doesn't return any data" do
        update_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Token validation response did not include a user'] })
      end
    end
  end

  describe 'PATCH /shopping_lists/:id' do
    subject(:update_shopping_list) { patch "/shopping_lists/#{list_id}", params: { shopping_list: { title: 'Severin Manor' } }.to_json, headers: }

    context 'when authenticated' do
      let!(:user) { create(:authenticated_user) }

      before do
        stub_successful_login
      end

      context 'when all goes well' do
        let!(:shopping_list) { create(:shopping_list, game:) }
        let(:game) { create(:game, user:) }
        let(:list_id) { shopping_list.id }

        it 'updates the title' do
          update_shopping_list
          expect(shopping_list.reload.title).to eq 'Severin Manor'
        end

        it 'returns the updated list' do
          update_shopping_list
          # This ugly hack is needed because if we don't parse the JSON, it'll make an error
          # if everything isn't in the exact same order, but if we just use shopping_list.attributes
          # it won't include the list_items. Ugly.
          expect(JSON.parse(response.body)).to eq(JSON.parse(shopping_list.reload.to_json))
        end

        it 'returns status 200' do
          update_shopping_list
          expect(response.status).to eq 200
        end
      end

      context 'when the params are invalid' do
        subject(:update_shopping_list) { patch "/shopping_lists/#{list_id}", params: { shopping_list: { title: other_list.title } }.to_json, headers: }

        let!(:shopping_list) { create(:shopping_list, game:) }
        let(:game) { create(:game, user:) }
        let(:list_id) { shopping_list.id }
        let(:other_list) { create(:shopping_list, game:) }

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns the errors' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Title must be unique per game'] })
        end
      end

      context 'when the list does not exist' do
        let(:list_id) { 245_285 }

        it 'returns status 404' do
          update_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return data" do
          update_shopping_list
          expect(response.body).to be_blank
        end
      end

      context 'when the list belongs to another user' do
        let!(:shopping_list) { create(:shopping_list) }
        let(:list_id) { shopping_list.id }

        it "doesn't update the shopping list" do
          expect { update_shopping_list }
            .not_to change(shopping_list.reload, :title)
        end

        it 'returns status 404' do
          update_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return data" do
          update_shopping_list
          expect(response.body).to be_blank
        end
      end

      context 'when the client attempts to update an aggregate list' do
        subject(:update_shopping_list) { patch "/shopping_lists/#{shopping_list.id}", params: { shopping_list: { title: 'Foo' } }.to_json, headers: }

        let!(:shopping_list) { create(:aggregate_shopping_list, game:) }
        let(:game) { create(:game, user:) }

        it "doesn't update the list" do
          update_shopping_list
          expect(shopping_list.reload.title).to eq 'All Items'
        end

        it 'returns status 405 (method not allowed)' do
          update_shopping_list
          expect(response.status).to eq 405
        end

        it 'returns a helpful error body' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually update an aggregate shopping list'] })
        end
      end

      context 'when the client attempts to change a regular list to an aggregate list' do
        subject(:update_shopping_list) { patch "/shopping_lists/#{shopping_list.id}", params: { shopping_list: { aggregate: true } }.to_json, headers: }

        let!(:shopping_list) { create(:shopping_list, game:) }
        let(:game) { create(:game, user:) }

        it "doesn't update the list" do
          update_shopping_list
          expect(shopping_list.reload.aggregate).to eq false
        end

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot make a regular shopping list an aggregate list'] })
        end
      end

      context 'when something unexpected goes wrong' do
        subject(:update_shopping_list) { patch "/shopping_lists/#{shopping_list.id}", params: { shopping_list: { title: 'Some New Title' } }.to_json, headers: }

        let!(:shopping_list) { create(:shopping_list, game:) }
        let(:game) { create(:game, user:) }

        before do
          allow_any_instance_of(User).to receive(:shopping_lists).and_raise(StandardError, 'Something went catastrophically wrong')
        end

        it 'returns status 500' do
          update_shopping_list
          expect(response.status).to eq 500
        end

        it 'returns the error in the body' do
          update_shopping_list
          expect(response.body).to eq({ errors: ['Something went catastrophically wrong'] }.to_json)
        end
      end
    end

    context 'when unauthenticated' do
      let!(:shopping_list) { create(:shopping_list) }
      let(:list_id) { shopping_list.id }

      before do
        stub_unsuccessful_login
      end

      it "doesn't update the shopping list" do
        expect { update_shopping_list }
          .not_to change(shopping_list.reload, :title)
      end

      it 'returns status 401' do
        update_shopping_list
        expect(response.status).to eq 401
      end

      it "doesn't return any data" do
        update_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Token validation response did not include a user'] })
      end
    end
  end

  describe 'GET games/:game_id/shopping_lists' do
    subject(:get_index) { get "/games/#{game.id}/shopping_lists", headers: }

    context 'when authenticated' do
      let!(:user) { create(:authenticated_user) }

      before do
        stub_successful_login
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

      context 'when the game belongs to another user' do
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

      context 'when there are no shopping lists for that game' do
        let(:game) { create(:game, user:) }

        it 'returns status 200' do
          get_index
          expect(response.status).to eq 200
        end

        it 'returns an empty array' do
          get_index
          expect(JSON.parse(response.body)).to eq []
        end
      end

      context 'when there are shopping lists for that game' do
        let(:game) { create(:game_with_shopping_lists, user:) }

        it 'returns status 200' do
          get_index
          expect(response.status).to eq 200
        end

        it 'returns the shopping lists in index order' do
          get_index
          expect(response.body).to eq game.shopping_lists.index_order.to_json
        end
      end
    end

    context 'when unauthenticated' do
      let!(:game) { create(:game) }

      before do
        stub_unsuccessful_login
      end

      it 'returns status 401' do
        get_index
        expect(response.status).to eq 401
      end

      it "doesn't return any data" do
        get_index
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Token validation response did not include a user'] })
      end
    end
  end

  describe 'DELETE /shopping_lists/:id' do
    subject(:delete_shopping_list) { delete "/shopping_lists/#{shopping_list.id}", headers: }

    context 'when authenticated' do
      let!(:user) { create(:authenticated_user) }
      let(:game) { create(:game, user:) }

      before do
        stub_successful_login
      end

      context 'when the shopping list exists' do
        let!(:shopping_list) { create(:shopping_list, game:) }

        context "when this is the game's last regular shopping list" do
          it 'deletes the shopping list and the aggregate list' do
            expect { delete_shopping_list }
              .to change(game.shopping_lists, :count).from(2).to(0)
          end

          it 'returns status 204' do
            delete_shopping_list
            expect(response.status).to eq 204
          end

          it "doesn't return any data" do
            delete_shopping_list
            expect(response.body).to be_blank
          end
        end

        context "when this is not the game's last regular shopping list" do
          before do
            create(:shopping_list, game:, aggregate_list: game.aggregate_shopping_list)
          end

          it 'deletes the requested shopping list' do
            expect { delete_shopping_list }
              .to change(game.shopping_lists, :count).from(3).to(2)
          end

          it 'returns status 200' do
            delete_shopping_list
            expect(response.status).to eq 200
          end

          it 'returns the aggregate list in the body' do
            delete_shopping_list
            expect(response.body).to eq(game.aggregate_shopping_list.to_json)
          end
        end
      end

      context 'when the shopping list does not exist' do
        let(:shopping_list) { double(id: 24_588) }

        it 'returns 404' do
          delete_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          delete_shopping_list
          expect(response.body).to be_blank
        end
      end

      context 'when the shopping list belongs to another user' do
        let!(:shopping_list) { create(:shopping_list) }

        it "doesn't destroy the shopping list" do
          expect { delete_shopping_list }
            .not_to change(ShoppingList, :count)
        end

        it 'returns 404' do
          delete_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          delete_shopping_list
          expect(response.body).to be_blank
        end
      end

      context 'when attempting to delete the aggregate list' do
        let!(:shopping_list) { create(:aggregate_shopping_list, game:) }

        it "doesn't delete the list" do
          expect { delete_shopping_list }
            .not_to change(ShoppingList, :count)
        end

        it 'returns status 405' do
          delete_shopping_list
          expect(response.status).to eq 405
        end

        it 'returns an "errors" array' do
          delete_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually delete an aggregate shopping list'] })
        end
      end
    end

    context 'when unauthenticated' do
      let!(:shopping_list) { create(:shopping_list) }

      before do
        stub_unsuccessful_login
      end

      it "doesn't destroy the shopping list" do
        expect { delete_shopping_list }
          .not_to change(ShoppingList, :count)
      end

      it 'returns status 401' do
        delete_shopping_list
        expect(response.status).to eq 401
      end

      it "doesn't return any data" do
        delete_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Token validation response did not include a user'] })
      end
    end
  end
end
