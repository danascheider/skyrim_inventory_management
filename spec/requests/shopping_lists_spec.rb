# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "ShoppingLists", type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer xxxxxxx'
    }
  end

  describe 'POST /shopping_lists' do
    subject(:create_shopping_list) { post '/shopping_lists', params: {}, headers: headers }

    context 'when authenticated' do
      let!(:user) { create(:user) }
      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user.email,
          'name' => user.name
        }
      end

      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when all goes well' do
        it 'creates a new shopping list' do
          expect { create_shopping_list }.to change(ShoppingList, :count).from(0).to(2) # because of the master list
        end

        it 'creates the list for the logged-in user' do
          create_shopping_list
          expect(ShoppingList.last.user).to eq user
        end

        it 'returns the new list' do
          create_shopping_list
          expect(response.body).to eq({ shopping_list: user.shopping_lists.first, master_list: user.master_shopping_list }.to_json)
        end

        it 'returns status 201' do
          create_shopping_list
          expect(response.status).to eq 201
        end
      end

      context 'when something goes wrong' do
        before do
          allow_any_instance_of(ShoppingList).to receive(:save).and_return(nil)
        end

        it 'returns status 422' do
          create_shopping_list
          expect(response.status).to eq 422
        end
      end
    end

    context 'when unauthenticated' do
      it 'returns 401' do
        create_shopping_list
        expect(response.status).to eq 401
      end
    end
  end

  describe 'GET /shopping_lists/:id' do
    subject(:get_shopping_list) { get "/shopping_lists/#{shopping_list_id}", headers: headers }

    context 'when unauthenticated' do
      let(:shopping_list) { create(:shopping_list) }
      let(:shopping_list_id) { shopping_list.id }

      it 'returns 401' do
        get_shopping_list
        expect(response.status).to eq 401
      end

      it 'returns an error in the body' do
        get_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Google OAuth token validation failed' })
      end
    end

    context 'when logged in as the wrong user' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      let(:shopping_list) { create(:shopping_list, user: user2) }
      let(:shopping_list_id) { shopping_list.id }
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user1.email,
          'name' => user1.name
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      it 'returns 404' do
        get_shopping_list
        expect(response.status).to eq 404
      end

      it 'does not return any data' do
        get_shopping_list
        expect(response.body).to be_empty
      end
    end

    context 'when the shopping list does not exist' do
      let(:user) { create(:user) }
      let(:shopping_list_id) { 24 } # could be anything
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user.email,
          'name' => user.name
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end
      
      it 'returns 404' do
        get_shopping_list
        expect(response.status).to eq 404
      end

      it 'does not return any data' do
        get_shopping_list
        expect(response.body).to be_empty
      end
    end

    context 'when authenticated and the shopping list exists' do
      let(:user) { create(:user) }
      let(:shopping_list) { create(:shopping_list, user: user) }
      let(:shopping_list_id) { shopping_list.id }
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user.email,
          'name' => user.name
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      it 'returns the shopping list' do
        get_shopping_list
        expect(response.body).to eq shopping_list.to_json
      end
    end
  end

  describe 'GET /shopping_lists' do
    subject(:get_index) { get '/shopping_lists', headers: headers }

    context 'when unauthenticated' do
      before do
        # create some data to not be returned
        create_list(:shopping_list, 3)
      end

      it 'returns 401' do
        get_index
        expect(response.status).to eq 401
      end

      it 'does not return any user data' do
        get_index
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Google OAuth token validation failed' })
      end
    end

    context 'when authenticated' do
      let(:authenticated_user) { create(:user) }
      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => authenticated_user.email,
          'name' => authenticated_user.name
        }
      end

      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }
      
      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)

        create_list(:shopping_list, 3, user: authenticated_user)
        unauthenticated_user = create(:user)
        create_list(:shopping_list, 3, user: unauthenticated_user)
      end

      it 'returns all shopping lists belonging to the authenticated user' do
        get_index
        expect(response.body).to eq authenticated_user.shopping_lists.to_json
      end

      it 'returns status 200' do
        get_index
        expect(response.status).to eq 200
      end
    end
  end

  describe 'DELETE /shopping_lists/:id' do
    subject(:delete_shopping_list) { delete "/shopping_lists/#{shopping_list_id}", headers: headers }

    context 'when unauthenticated' do
      let!(:shopping_list) { create(:shopping_list) }
      let(:shopping_list_id) { shopping_list.id }

      it 'returns 401' do
        delete_shopping_list
        expect(response.status).to eq 401
      end

      it 'does not delete the shopping list' do
        expect { delete_shopping_list }.not_to change(ShoppingList, :count)
      end

      it 'returns an error in the body' do
        delete_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Google OAuth token validation failed' })
      end
    end

    context 'when logged in as the wrong user' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      let!(:shopping_list) { create(:shopping_list, user: user2) }
      let(:shopping_list_id) { shopping_list.id }
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user1.email,
          'name' => user1.name
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      it 'returns 404' do
        delete_shopping_list
        expect(response.status).to eq 404
      end

      it 'does not return any data' do
        delete_shopping_list
        expect(response.body).to be_empty
      end

      it 'does not delete any shopping lists' do
        expect { delete_shopping_list }.not_to change(ShoppingList, :count)
      end
    end

    context 'when the shopping list does not exist' do
      let(:user) { create(:user) }
      let(:shopping_list_id) { 24 } # could be anything
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user.email,
          'name' => user.name
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end
      
      it 'returns 404' do
        delete_shopping_list
        expect(response.status).to eq 404
      end

      it 'does not return any data' do
        delete_shopping_list
        expect(response.body).to be_empty
      end
    end

    context 'when authenticated and the shopping list exists' do
      let(:user) { create(:user) }
      let!(:shopping_list) { create(:shopping_list, user: user) }
      let(:shopping_list_id) { shopping_list.id }
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user.email,
          'name' => user.name
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context "when this is the user's last regular shopping list" do
        it 'deletes the shopping list' do
          expect { delete_shopping_list }.to change(ShoppingList, :count).from(2).to(0)
        end

        it 'returns status 204' do
          delete_shopping_list
          expect(response.status).to eq 204
        end

        it "doesn't include any data" do
          delete_shopping_list
          expect(response.body).to be_empty
        end
      end

      context "when this is not the user's last regular shopping list" do
        before do
          create(:shopping_list, user: user)
        end

        it 'deletes the shopping list' do
          expect { delete_shopping_list }.to change(user.shopping_lists, :count).from(3).to(2)
        end

        it 'returns status 200' do
          delete_shopping_list
          expect(response.status).to eq 200
        end

        it 'returns the master list in the body' do
          delete_shopping_list
          expect(response.body).to eq({ master_list: user.master_shopping_list }.to_json)
        end
      end
    end

    context 'when properly authenticated and attempting to delete the master list' do
      let(:user) { create(:user) }
      let(:shopping_list_id) { shopping_list.id }
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user.email,
          'name' => user.name
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when no other list exists' do
        let!(:shopping_list) { create(:master_shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        it 'deletes the master list' do
          expect { delete_shopping_list }.to change(user.shopping_lists, :count).from(1).to(0)
        end

        it 'returns status 204' do
          delete_shopping_list
          expect(response.status).to eq 204
        end
      end

      context 'when another list exists' do
        let!(:shopping_list) { create(:master_shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        before do
          create(:shopping_list, user: user)
        end

        it 'does not delete anything' do
          expect { delete_shopping_list }.not_to change(ShoppingList, :count)
        end

        it 'returns status 405 (Method Not Allowed)' do
          delete_shopping_list
          expect(response.status).to eq 405
        end
      end
    end
  end
end
