# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "ShoppingLists", type: :request do
  describe 'POST /shopping_lists' do
    subject(:create_shopping_list) { post '/shopping_lists', params: {}, headers: headers }

    let(:headers) do
      {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer xxxxxxx'
      }
    end

    context 'when authenticated' do
      let!(:user) { create(:user) }
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

      context 'when all goes well' do
        it 'creates a new shopping list' do
          expect { create_shopping_list }.to change(ShoppingList, :count).from(0).to(1)
        end

        it 'creates the list for the logged-in user' do
          create_shopping_list
          expect(ShoppingList.last.user).to eq user
        end

        it 'returns the new list' do
          create_shopping_list
          expect(response.body).to eq ShoppingList.last.to_json
        end

        it 'returns status 201' do
          create_shopping_list
          expect(response.status).to eq 201
        end
      end

      context 'when something goes wrong' do
        before do
          puts "User: #{user.id}"
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
end
