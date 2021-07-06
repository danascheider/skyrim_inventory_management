# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ShoppingListItems', type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer xxxxxxx'
    }
  end

  describe 'POST /shopping_lists/:shopping_list_id/shopping_list_items' do
    subject(:create_item) do
      post "/shopping_lists/#{shopping_list.id}/shopping_list_items",
           params: params.to_json,
           headers: headers
    end

    let!(:master_list) { create(:master_shopping_list) }
    let!(:shopping_list) { create(:shopping_list, user: master_list.user) }
    
    context 'when authenticated' do
      let!(:user) { master_list.user }
      
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
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

        it 'creates a new shopping list item on the shopping list' do
          expect { create_item }.to change(shopping_list.list_items, :count).from(0).to(1)
        end

        context 'when the master list has no items on it' do
          it 'adds the item to the master list' do
            expect { create_item }.to change(ShoppingListItem, :count).from(0).to(2)
          end

          it 'assigns the right attributes' do
            create_item
            item = shopping_list.list_items.last
            expect(master_list.list_items.last.attributes).to include(
              'description' => item.description,
              'quantity' => item.quantity,
              'notes' => item.notes
            )
          end

          it 'returns the master list item and the regular list item' do
            create_item
            expect(response.body).to eq([master_list.list_items.last, shopping_list.list_items.last].to_json)
          end

          it 'returns status 201' do
            create_item
            expect(response.status).to eq 201
          end
        end

        context 'when the master list has a matching item' do
          before do
            second_list = user.shopping_lists.create!(title: 'Proudspire Manor', master_list: master_list)
            second_list.list_items.create!(
              description: 'Corundum ingot',
              quantity: 1,
              notes: 'some other notes'
            )
            master_list.add_item_from_child_list(second_list.list_items.last)
          end

          it 'updates the item on the master list', :aggregate_failures do
            create_item
            expect(master_list.list_items.count).to eq 1
            expect(master_list.list_items.last.attributes).to include(
              'description' => 'Corundum ingot',
              'quantity' => 6,
              'notes' => 'some other notes -- To make locks'
            )
          end

          it 'returns the master list item and the regular list item', :aggregate_failures do
            create_item

            # The serialization isn't as simple as .to_json and it makes it hard to determine if the JSON
            # string is correct as some attributes are out of order and the timestamps are serialized
            # differently. Here we grab the individual items and then we'll filter out the timestamps to
            # verify them.
            master_list_item_actual, regular_list_item_actual = JSON.parse(response.body).map do |item_attrs|
              item_attrs.reject { |key, value| %w[created_at updated_at].include?(key) }
            end

            master_list_item_expected = master_list.list_items.last.attributes.reject { |k, v| %w[created_at updated_at].include?(k) }
            regular_list_item_expected = shopping_list.list_items.last.attributes.reject { |k, v| %w[created_at updated_at].include?(k) }
  
            expect(master_list_item_actual).to eq(master_list_item_expected)
            expect(regular_list_item_actual).to eq(regular_list_item_expected)
          end

          it 'returns status 201' do
            create_item
            expect(response.status).to eq 201
          end

          it 'updates the regular list', :aggregate_failures do
            t = Time.now + 3.days

            Timecop.freeze(t) do
              create_item
              # use `be_within` even though the time will be set to the time Timecop
              # has frozen because Rails (Postgres?) sets the last three digits of
              # the timestamp to 0, which was breaking stuff in CI (but somehow not
              # in dev).
              expect(shopping_list.reload.updated_at).to be_within(0.05.seconds).of(t)
              expect(master_list.reload.updated_at).not_to be_within(0.05.seconds).of(t)
            end
          end
        end

        context 'when the new item matches an existing item on the list' do
          before do
            shopping_list.list_items.create!(description: 'Corundum ingot', quantity: 2, notes: 'To make locks')
          end

          it "doesn't create a new item" do
            expect { create_item }.not_to change(shopping_list.list_items, :count)
          end

          it 'updates the existing item' do
            create_item
            expect(shopping_list.list_items.first.attributes).to include(
              'description' => 'Corundum ingot',
              'quantity' => 7,
              'notes' => 'To make locks -- To make locks'
            )
          end
        end
      end

      context 'when the shopping list belongs to a different user' do
        let(:user) { create(:user) }
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

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
               params: params.to_json,
               headers: headers
        end

        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

        it 'returns 404' do
          create_item
          expect(response.status).to eq 404
        end

        it 'returns no body' do
          create_item
          expect(response.body).to be_empty
        end
      end

      context 'when the shopping list is a master list' do
        let(:shopping_list) { master_list }

        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

        it 'returns status 405' do
          create_item
          expect(response.status).to eq 405
        end
      end

      context 'when the params are invalid' do
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 'fooooo', notes: 'To make locks' } } }

        it 'returns 422' do
          create_item
          expect(response.status).to eq 422
        end

        it 'returns the validation errors' do
          create_item
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Quantity is not a number'] })
        end
      end
    end

    context 'when unauthenticated' do
      let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

      it 'returns 401' do
        create_item
        expect(response.status).to eq 401
      end

      it 'returns a helpful error' do
        create_item
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Google OAuth token validation failed'] })
      end
    end
  end

  describe 'PATCH /shopping_list_items/:id' do
    subject(:update_item) do
      patch "/shopping_list_items/#{list_item.id}", params: params.to_json, headers: headers
    end

    let!(:master_list) { create(:master_shopping_list) }
    let!(:shopping_list) { create(:shopping_list_with_list_items, user: master_list.user) }
    
    context 'when authenticated' do
      let!(:user) { master_list.user }
      
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
        let(:params) { { shopping_list_item: { quantity: 5, notes: 'To make locks' } } }
        let(:list_item) { shopping_list.list_items.first }

        before do
          second_list = create(:shopping_list, user: user, master_list: master_list)
          second_list.list_items.create!(description: list_item.description, quantity: 2)
          master_list.add_item_from_child_list(shopping_list.list_items.first)
          master_list.add_item_from_child_list(shopping_list.list_items.last) # for the sake of realism
          master_list.add_item_from_child_list(second_list.list_items.first) 
        end

        it 'updates the regular list item' do
          update_item
          expect(list_item.reload.attributes).to include(
                                                          'quantity' => 5,
                                                          'notes' => 'To make locks'
                                                        )
        end

        it 'updates the item on the master list' do
          update_item
          expect(master_list.list_items.first.attributes).to include(
                                                                      'description' => list_item.description,
                                                                      'quantity' => 7,
                                                                      'notes' => 'To make locks'
                                                                    )
        end

        it 'updates the regular list', :aggregate_failures do
          t = Time.now + 3.days

          Timecop.freeze(t) do
            update_item
            # use `be_within` even though the time will be set to the time Timecop
            # has frozen because Rails (Postgres?) sets the last three digits of
            # the timestamp to 0, which was breaking stuff in CI (but somehow not
            # in dev).
            expect(shopping_list.reload.updated_at).to be_within(0.05.seconds).of(t)
            expect(master_list.reload.updated_at).not_to be_within(0.05.seconds).of(t)
          end
        end

        it 'returns the master list item and the regular list item', :aggregate_failures do
          update_item

          # The serialization isn't as simple as .to_json and it makes it hard to determine if the JSON
          # string is correct as some attributes are out of order and the timestamps are serialized
          # differently. Here we grab the individual items and then we'll filter out the timestamps to
          # verify them.
          master_list_item_actual, regular_list_item_actual = JSON.parse(response.body).map do |item_attrs|
            item_attrs.reject { |key, value| %w[created_at updated_at].include?(key) }
          end

          master_list_item_expected = master_list.list_items.first.attributes.reject { |k, v| %w[created_at updated_at].include?(k) }
          regular_list_item_expected = shopping_list.list_items.first.attributes.reject { |k, v| %w[created_at updated_at].include?(k) }

          expect(master_list_item_actual).to eq(master_list_item_expected)
          expect(regular_list_item_actual).to eq(regular_list_item_expected)
        end

        it 'returns status 200' do
          update_item
          expect(response.status).to eq 200
        end
      end

      context 'when the shopping list belongs to a different user' do
        let(:user) { create(:user) }
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }
        let(:list_item) { create(:shopping_list_item) }

        it 'returns 404' do
          update_item
          expect(response.status).to eq 404
        end

        it 'does not return content' do
          update_item
          expect(response.body).to be_empty
        end
      end

      context 'when the shopping list does not exist' do
        let(:user) { create(:user) }
        let(:list_item) { double("this item doesn't exist", id: 8942) }
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

        it 'returns 404' do
          update_item
          expect(response.status).to eq 404
        end

        it 'returns no body' do
          update_item
          expect(response.body).to be_empty
        end
      end

      context 'when the shopping list is a master list' do
        let(:shopping_list) { user.master_shopping_list }
        let(:list_item) { shopping_list.list_items.create!(description: 'Corundum Ingot', list: shopping_list) }

        let(:params) {  { shopping_list_item: { 'quantity': 5, notes: 'To make locks' } } }

        it 'does not update the list', :aggregate_failures do
          update_item
          expect(list_item.quantity).to eq 1
          expect(list_item.notes).to be nil
        end

        it 'returns status 405' do
          update_item
          expect(response.status).to eq 405
        end

        it 'returns a helpful error' do
          update_item
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually update list items on a master shopping list'] })
        end
      end

      context 'when the params are invalid' do
        let(:list_item) { shopping_list.list_items.create!(description: 'Corundum ingot') }
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 'foooo', notes:'To make locks' } } }

        before do
          master_list.add_item_from_child_list(list_item)
        end

        it 'does not update the master list', :aggregate_failures do
          update_item
          expect(master_list.list_items.first.quantity).to eq 1
          expect(master_list.list_items.first.notes).to be nil
        end

        it 'returns 422' do
          update_item
          expect(response.status).to eq 422
        end

        it 'returns the validation errors' do
          update_item
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Quantity is not a number'] })
        end
      end
    end

    context 'when unauthenticated' do
      let(:user) { create(:user) }
      let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 4, notes: 'To make locks' } } }
      let(:list_item) { create(:shopping_list_item, list: shopping_list) }

      it 'returns 401' do
        update_item
        expect(response.status).to eq 401
      end

      it 'returns a helpful error' do
        update_item
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Google OAuth token validation failed'] })
      end
    end
  end
end
