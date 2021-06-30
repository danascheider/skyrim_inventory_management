# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ShoppingLists', type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer xxxxxxx'
    }
  end

  describe 'POST /shopping_lists' do
    subject(:create_shopping_list) { post '/shopping_lists', params: '{ "shopping_list": {} }', headers: headers }

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
        context 'when a master list has also been created' do
          it 'creates a new shopping list' do
            expect { create_shopping_list }.to change(user.shopping_lists, :count).from(0).to(2) # because of the master list
          end

          it 'returns the master list as well as the new list' do
            create_shopping_list
            expect(response.body).to eq([user.master_shopping_list, user.shopping_lists.first].to_json)
          end

          it 'returns status 201' do
            create_shopping_list
            expect(response.status).to eq 201
          end
        end

        context 'when only the new shopping list has been created' do
          let!(:master_list) { create(:master_shopping_list, user: user, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }

          it 'creates one list' do
            expect{ create_shopping_list }.to change(user.shopping_lists, :count).from(1).to(2)
          end

          it 'returns only the newly created list' do
            create_shopping_list
            expect(response.body).to eq([user.shopping_lists.last].to_json)
          end
        end
      end

      context 'when something goes wrong' do
        subject(:create_shopping_list) { post '/shopping_lists', params: "{ \"shopping_list\": { \"title\": \"#{existing_list.title}\" } }", headers: headers }
        let(:existing_list) { create(:shopping_list, user: user) }

        it 'returns status 422' do
          create_shopping_list
          expect(response.status).to eq 422
        end

        it "returns the errors" do
          create_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'title' => ['has already been taken'] } })
        end
      end

      context 'when the client attempts to create a master list' do
        subject(:create_shopping_list) { post '/shopping_lists', params: '{ "shopping_list": { "master": true } }', headers: headers }

        it "doesn't create a list" do
          expect { create_shopping_list }.not_to change(ShoppingList, :count)
        end

        it 'returns an error' do
          create_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          create_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'master' => ['cannot create or update a master shopping list through the API'] } })
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

      it 'returns an error message indicating the list was not found' do
        get_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'error' => "Shopping list id=#{shopping_list_id} not found" })
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

      it 'returns an error message indicating the list was not found' do
        get_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'error' => "Shopping list id=#{shopping_list_id} not found" })
      end
    end

    context 'when authenticated and the shopping list exists' do
      let(:user) { create(:user) }
      let(:shopping_list) { create(:shopping_list_with_list_items, list_item_count: 2, user: user) }
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

      it 'returns the shopping list with its list items' do
        get_shopping_list
        expect(response.body).to eq shopping_list.to_json(include: :shopping_list_items)
      end
    end
  end

  describe 'PUT /shopping_lists/:id' do
    subject(:update_shopping_list) { put "/shopping_lists/#{shopping_list_id}", params: '{ "shopping_list": { "title": "Severin Manor" } }', headers: headers }

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
        let!(:shopping_list) { create(:shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        it 'updates the title' do
          update_shopping_list
          expect(shopping_list.reload.title).to eq 'Severin Manor'
        end

        it 'returns the updated list' do
          update_shopping_list
          # This ugly hack is needed because if we don't parse the JSON, it'll make an error
          # if everything isn't in the exact same order, but if we just use shopping_list.attributes
          # it won't include the shopping_list_items. Ugly.
          expect(JSON.parse(response.body)).to eq(JSON.parse(shopping_list.reload.to_json))
        end

        it 'returns status 200' do
          update_shopping_list
          expect(response.status).to eq 200
        end
      end

      context 'when something goes wrong' do
        subject(:update_shopping_list) { put "/shopping_lists/#{shopping_list_id}", params: "{ \"shopping_list\": { \"title\": \"#{other_list.title}\" } }", headers: headers }

        let!(:shopping_list) { create(:shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }
        let(:other_list) { create(:shopping_list, user: user) }

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it "returns the errors" do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'title' => ['has already been taken'] } })
        end
      end

      context 'when the list belongs to a different user' do
        let!(:shopping_list) { create(:shopping_list) }
        let(:shopping_list_id) { shopping_list.id }

        it 'returns status 404' do
          update_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return data" do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'error' => "Shopping list id=#{shopping_list_id} not found" })
        end
      end

      context 'when the client attempts to update a master list' do
        subject(:update_shopping_list) { put "/shopping_lists/#{shopping_list_id}", params: '{ "shopping_list": { "title": "Foo" } }', headers: headers }

        let!(:shopping_list) { create(:master_shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        it "doesn't update the list" do
          update_shopping_list
          expect(shopping_list.reload.title).to eq 'Master'
        end

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'master' => ['cannot create or update a master shopping list through the API'] } })
        end
      end

      context 'when the client attempts to change a regular list to a master list' do
        subject(:update_shopping_list) { put "/shopping_lists/#{shopping_list_id}", params: '{ "shopping_list": { "master": true } }', headers: headers }
        
        let!(:shopping_list) { create(:shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        it "doesn't update the list" do
          update_shopping_list
          expect(shopping_list.reload.master).to eq false
        end

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'master' => ['cannot create or update a master shopping list through the API'] } })
        end
      end
    end

    context 'when unauthenticated' do
      let(:shopping_list_id) { 42 }

      it 'returns 401' do
        update_shopping_list
        expect(response.status).to eq 401
      end
    end
  end

  describe 'PATCH /shopping_lists/:id' do
    subject(:update_shopping_list) { patch "/shopping_lists/#{shopping_list_id}", params: '{ "shopping_list": { "title": "Severin Manor" } }', headers: headers }

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
        let!(:shopping_list) { create(:shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        it 'updates the title' do
          update_shopping_list
          expect(shopping_list.reload.title).to eq 'Severin Manor'
        end

        it 'returns the updated list' do
          update_shopping_list
          # This ugly hack is needed because if we don't parse the JSON, it'll make an error
          # if everything isn't in the exact same order, but if we just use shopping_list.attributes
          # it won't include the shopping_list_items. Ugly.
          expect(JSON.parse(response.body)).to eq(JSON.parse(shopping_list.reload.to_json))
        end

        it 'returns status 200' do
          update_shopping_list
          expect(response.status).to eq 200
        end
      end

      context 'when something goes wrong' do
        subject(:update_shopping_list) { patch "/shopping_lists/#{shopping_list_id}", params: "{ \"shopping_list\": { \"title\": \"#{other_list.title}\" } }", headers: headers }

        let!(:shopping_list) { create(:shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }
        let(:other_list) { create(:shopping_list, user: user) }

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it "returns the errors" do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'title' => ['has already been taken'] } })
        end
      end

      context 'when the list belongs to a different user' do
        let!(:shopping_list) { create(:shopping_list) }
        let(:shopping_list_id) { shopping_list.id }

        it 'returns status 404' do
          update_shopping_list
          expect(response.status).to eq 404
        end

        it "doesn't return data" do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'error' => "Shopping list id=#{shopping_list_id} not found" })
        end
      end

      context 'when the client attempts to update a master list' do
        subject(:update_shopping_list) { patch "/shopping_lists/#{shopping_list_id}", params: '{ "shopping_list": { "title": "Foo" } }', headers: headers }

        let!(:shopping_list) { create(:master_shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        it "doesn't update the list" do
          update_shopping_list
          expect(shopping_list.reload.title).to eq 'Master'
        end

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'master' => ['cannot create or update a master shopping list through the API'] } })
        end
      end

      context 'when the client attempts to change a regular list to a master list' do
        subject(:update_shopping_list) { patch "/shopping_lists/#{shopping_list_id}", params: '{ "shopping_list": { "master": true } }', headers: headers }
        
        let!(:shopping_list) { create(:shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        it "doesn't update the list" do
          update_shopping_list
          expect(shopping_list.reload.master).to eq false
        end

        it 'returns status 422' do
          update_shopping_list
          expect(response.status).to eq 422
        end

        it 'returns a helpful error body' do
          update_shopping_list
          expect(JSON.parse(response.body)).to eq({ 'errors' => { 'master' => ['cannot create or update a master shopping list through the API'] } })
        end
      end
    end

    context 'when unauthenticated' do
      let(:shopping_list_id) { 42 }

      it 'returns 401' do
        update_shopping_list
        expect(response.status).to eq 401
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

      it 'returns an error body indicating authorisation failed' do
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

        user_list = create_list(:shopping_list_with_list_items, 3, list_item_count: 2, user: authenticated_user)
        unauthenticated_user = create(:user)
        create_list(:shopping_list, 3, user: unauthenticated_user)

        user_list[1].update!(title: 'New title')   
      end

      it 'returns all shopping lists belonging to the authenticated user' do
        get_index
        expect(JSON.parse(response.body)).to eq JSON.parse(authenticated_user.shopping_lists.index_order.to_json(include: :shopping_list_items))
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

      it 'returns an error message indicating the list was not found' do
        delete_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'error' => "Shopping list id=#{shopping_list_id} not found" })
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

      it 'returns an error message indicating the list was not found' do
        delete_shopping_list
        expect(JSON.parse(response.body)).to eq({ 'error' => "Shopping list id=#{shopping_list_id} not found" })
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

      context 'when another list exists' do
        let!(:shopping_list) { create(:master_shopping_list, user: user) }
        let(:shopping_list_id) { shopping_list.id }

        it 'does not delete anything' do
          expect { delete_shopping_list }.not_to change(ShoppingList, :count)
        end

        it 'returns status 405 (Method Not Allowed)' do
          delete_shopping_list
          expect(response.status).to eq 405
        end

        it 'returns a helpful error body' do
          delete_shopping_list
          expect(response.body).to eq({ error: 'cannot destroy a master shopping list through the API' }.to_json)
        end
      end
    end
  end
end
