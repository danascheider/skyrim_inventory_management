# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ShoppingListItems', type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer xxxxxxx'
    }
  end

  describe 'POST /shopping_lists/:id/shopping_list_items' do
    subject(:create_item) do
      post "/shopping_lists/#{shopping_list.id}/shopping_list_items",
           params: params,
           headers: headers
    end

    let(:shopping_list) { create(:shopping_list) }
    
    context 'when authenticated' do
      let!(:user) { shopping_list.user }
      
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
        let(:params) { "{\"shopping_list_item\":{\"description\":\"Corundum ingot\",\"quantity\":5,\"notes\":\"To make locks\",\"shopping_list_id\":#{shopping_list.id}}}" }

        it 'creates a new shopping list item on the shopping list' do
          expect { create_item }.to change(shopping_list.shopping_list_items, :count).from(0).to(1)
        end

        context 'when the master list has no items on it' do
          let(:master_list) { user.master_shopping_list }

          it 'adds the item to the master list' do
            expect { create_item }.to change(ShoppingListItem, :count).from(0).to(2)
          end

          it 'assigns the right attributes' do
            create_item
            item = shopping_list.shopping_list_items.last
            expect(master_list.shopping_list_items.last.attributes).to include(
              'description' => item.description,
              'quantity' => item.quantity,
              'notes' => item.notes
            )
          end

          it 'returns the master list item and the regular list item' do
            create_item
            expect(response.body).to eq([master_list.shopping_list_items.last, shopping_list.shopping_list_items.last].to_json)
          end

          it 'returns status 201' do
            create_item
            expect(response.status).to eq 201
          end
        end

        context 'when the master list has a matching item' do
          let(:master_list) { user.master_shopping_list }

          before do
            second_list = user.shopping_lists.create!(title: 'Proudspire Manor')
            second_list.shopping_list_items.create!(
              description: 'Corundum ingot',
              quantity: 1,
              notes: 'some other notes'
            )
          end

          it 'updates the item on the master list', :aggregate_failures do
            create_item
            expect(master_list.shopping_list_items.count).to eq 1
            expect(master_list.shopping_list_items.last.attributes).to include(
              'description' => 'Corundum ingot',
              'quantity' => 6,
              'notes' => 'some other notes -- To make locks'
            )
          end

          it 'returns the master list item and the regular list item' do
            create_item
            expect(response.body).to eq([master_list.shopping_list_items.last, shopping_list.shopping_list_items.last].to_json)
          end

          it 'returns status 201' do
            create_item
            expect(response.status).to eq 201
          end
        end
      end

      context 'when the shopping list belongs to a different user' do
        let(:user) { create(:user) }
        let(:params) { "{\"shopping_list_item\":{\"description\":\"Corundum ingot\",\"quantity\":5,\"notes\":\"To make locks\",\"shopping_list_id\":#{shopping_list.id}}}" }

        it 'returns 404' do
          create_item
          expect(response.status).to eq 404
        end

        it 'does not return content' do
          create_item
          expect(response.body).to be_empty
        end
      end

      context 'when the shopping list does not exist' do
        subject(:create_item) do
          post '/shopping_lists/838934/shopping_list_items',
               params: params,
               headers: headers
        end

        let(:params) { "{\"shopping_list_item\":{\"description\":\"Corundum ingot\",\"quantity\":5,\"notes\":\"To make locks\",\"shopping_list_id\":#{shopping_list.id}}}" }

        it 'returns 404' do
          create_item
          expect(response.status).to eq 404
        end

        it 'returns no body' do
          create_item
          expect(response.body).to be_empty
        end
      end

      context 'when the params are invalid' do
        let(:params) { "{\"shopping_list_item\":{\"description\":\"Corundum ingot\",\"quantity\":\"foooo\",\"notes\":\"To make locks\",\"shopping_list_id\":#{shopping_list.id}}}" }

        it 'returns 422' do
          create_item
          expect(response.status).to eq 422
        end

        it 'returns the validation errors' do
          create_item
          expect(JSON.parse(response.body)).to eq({
            'errors' => {
              'quantity' => ['is not a number']
            }
          })
        end
      end
    end

    context 'when unauthenticated' do
      let(:params) { "{\"shopping_list_item\":{\"description\":\"Corundum ingot\",\"quantity\":4,\"notes\":\"To make locks\",\"shopping_list_id\":#{shopping_list.id}}}" }

      it 'returns 401' do
        create_item
        expect(response.status).to eq 401
      end

      it 'returns a helpful error' do
        create_item
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Google OAuth token validation failed' })
      end
    end
  end
end
