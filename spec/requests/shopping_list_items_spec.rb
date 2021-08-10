# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ShoppingListItems', type: :request do
  let(:headers) do
    {
      'Content-Type'  => 'application/json',
      'Authorization' => 'Bearer xxxxxxx',
    }
  end

  describe 'POST /shopping_lists/:shopping_list_id/shopping_list_items' do
    subject(:create_item) do
      post "/shopping_lists/#{shopping_list.id}/shopping_list_items",
           params:  params.to_json,
           headers: headers
    end

    let!(:aggregate_list) { create(:aggregate_shopping_list) }
    let!(:shopping_list)  { create(:shopping_list, aggregate_list: aggregate_list, game: aggregate_list.game) }

    context 'when authenticated' do
      let!(:user)     { aggregate_list.user }
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      let(:validation_data) do
        {
          'exp'   => (Time.zone.now + 1.year).to_i,
          'email' => user.email,
          'name'  => user.name,
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when all goes well' do
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

        context 'when there is no existing matching item on the same list' do
          context 'when there is no existing matching item on any list' do
            it 'creates a new item on the requested list' do
              expect { create_item }
                .to change(shopping_list.list_items, :count).from(0).to(1)
            end

            it 'creates a new item on the aggregate list' do
              expect { create_item }
                .to change(aggregate_list.list_items, :count).from(0).to(1)
            end

            it 'returns status 201' do
              create_item
              expect(response.status).to eq 201
            end

            it 'returns the regular list item and the aggregate list item' do
              create_item
              expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list.list_items.last, shopping_list.list_items.last].to_json))
            end
          end

          context 'when there is an existing matching item on another list' do
            let(:other_list)  { create(:shopping_list, game: aggregate_list.game) }
            let!(:other_item) { create(:shopping_list_item, list: other_list, description: 'Corundum ingot', quantity: 2) }

            before do
              aggregate_list.add_item_from_child_list(other_item)
            end

            context "when unit weight isn't set" do
              let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5 } } }

              it 'creates a new item on the requested list' do
                expect { create_item }
                  .to change(shopping_list.list_items, :count).from(0).to(1)
              end

              it 'updates the item on the aggregate list' do
                create_item
                expect(aggregate_list.list_items.first.quantity).to eq 7
              end

              it 'returns status 201' do
                create_item
                expect(response.status).to eq 201
              end

              it 'returns the aggregate list item and the regular list item' do
                create_item
                expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list.list_items.first, shopping_list.list_items.first].to_json))
              end
            end

            context 'when unit weight is set' do
              let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, unit_weight: 1 } } }

              it 'creates a new item on the requested list' do
                expect { create_item }
                  .to change(shopping_list.list_items, :count).from(0).to(1)
              end

              it 'updates the item on the aggregate list', :aggregate_failures do
                create_item
                expect(aggregate_list.list_items.first.quantity).to eq 7
                expect(aggregate_list.list_items.first.unit_weight).to eq 1
              end

              it 'updates the unit weight of the other regular-list item', :aggregate_failures do
                create_item
                expect(other_item.reload.unit_weight).to eq 1
                expect(other_item.reload.quantity).to eq 2
              end

              it 'returns status 201' do
                create_item
                expect(response.status).to eq 201
              end

              it 'returns all items that were created or updated' do
                create_item
                expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list.list_items.first, other_item.reload, shopping_list.list_items.first].to_json))
              end
            end
          end
        end

        context 'when there is an existing matching item on the same list' do
          let(:other_list) { create(:shopping_list, game: aggregate_list.game, aggregate_list: aggregate_list) }
          let!(:other_item) { create(:shopping_list_item, list: other_list, description: 'Corundum ingot', quantity: 2) }
          let!(:list_item)  { create(:shopping_list_item, list: shopping_list, description: 'Corundum ingot', quantity: 3) }

          before do
            aggregate_list.add_item_from_child_list(other_item)
            aggregate_list.add_item_from_child_list(list_item)
          end

          context "when unit weight isn't updated" do
            it "doesn't create a new item" do
              expect { create_item }
                .not_to change(ShoppingListItem, :count)
            end

            it 'combines with the existing item' do
              create_item
              expect(list_item.reload.quantity).to eq 8
            end

            it 'updates the item on the aggregate list' do
              create_item
              expect(aggregate_list.list_items.first.quantity).to eq 10
            end

            it 'returns status 200' do
              create_item
              expect(response.status).to eq 200
            end

            it 'returns the requested item and the aggregate list item' do
              create_item
              expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list.list_items.first, list_item.reload].to_json))
            end
          end

          context 'when unit weight is updated' do
            let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 2, unit_weight: 1 } } }

            it "doesn't create a new list item" do
              expect { create_item }
                .not_to change(ShoppingListItem, :count)
            end

            it 'combines it with the existing item', :aggregate_failures do
              create_item
              expect(list_item.reload.quantity).to eq 5
              expect(list_item.unit_weight).to eq 1
            end

            it 'updates the item on the aggregate list', :aggregate_failures do
              create_item
              expect(aggregate_list.list_items.first.quantity).to eq 7
              expect(aggregate_list.list_items.first.unit_weight).to eq 1
            end

            it 'updates only the unit_weight on the other item', :aggregate_failures do
              create_item
              expect(other_item.reload.unit_weight).to eq 1
              expect(other_item.quantity).to eq 2
            end

            it 'returns status 200' do
              create_item
              expect(response.status).to eq 200
            end

            it 'returns all items that have been updated' do
              create_item
              expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list.list_items.first, other_item.reload, list_item.reload].to_json))
            end
          end
        end
      end

      context "when the list doesn't exist" do
        let(:params)         { { description: 'Necklace', quantity: 2, unit_weight: 0.5 } }
        let(:shopping_list)  { double(id: 23_498) }

        it 'returns status 404' do
          create_item
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          create_item
          expect(response.body).to be_blank
        end
      end

      context "when the list doesn't belong to the authenticated user" do
        let(:shopping_list) { create(:shopping_list) }
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 5 } } }

        it "doesn't create the list item" do
          expect { create_item }
            .not_to change(ShoppingListItem, :count)
        end

        it 'returns status 404' do
          create_item
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          create_item
          expect(response.body).to be_blank
        end
      end

      context 'when the params are invalid' do
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: -2 } } }

        it "doesn't create the item" do
          expect { create_item }
            .not_to change(ShoppingListItem, :count)
        end

        it 'returns status 422' do
          create_item
          expect(response.status).to eq 422
        end

        it 'returns the error array' do
          create_item
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Quantity must be greater than 0'] })
        end
      end

      context 'when the list is an aggregate list' do
        let(:shopping_list) { aggregate_list }
        let(:params)        { { shopping_list_item: { description: 'Corundum ingot', quantity: 4 } } }

        it "doesn't create an item" do
          expect { create_item }
            .not_to change(ShoppingListItem, :count)
        end

        it 'returns status 405' do
          create_item
          expect(response.status).to eq 405
        end

        it 'returns the error' do
          create_item
          expect(JSON.parse(response.body))
            .to eq({ 'errors' => ['Cannot manually manage items on an aggregate shopping list'] })
        end
      end

      context 'when something unexpected goes wrong' do
        let(:params) { { shopping_list_item: { description: 'Corundum ingot', quantity: 4 } } }

        before do
          allow(ShoppingList).to receive(:find).and_raise(StandardError.new('Something went horribly wrong'))
        end

        it 'returns status 500' do
          create_item
          expect(response.status).to eq 500
        end

        it 'returns the error' do
          create_item
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Something went horribly wrong'] })
        end
      end
    end
  end

  describe 'PATCH /shopping_list_items/:id' do
    subject(:update_item) do
      patch "/shopping_list_items/#{list_item.id}", params: params.to_json, headers: headers
    end

    let!(:aggregate_list) { create(:aggregate_shopping_list) }
    let!(:shopping_list)  { create(:shopping_list_with_list_items, game: aggregate_list.game) }

    context 'when authenticated' do
      let!(:user) { aggregate_list.user }

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
        let(:params)    { { shopping_list_item: { quantity: 5, notes: 'To make locks' } } }
        let(:game)      { aggregate_list.game }
        let(:list_item) { shopping_list.list_items.first }

        before do
          second_list = create(:shopping_list, game: game, aggregate_list: aggregate_list)
          second_list.list_items.create!(description: list_item.description, quantity: 2)
          aggregate_list.add_item_from_child_list(shopping_list.list_items.first)
          aggregate_list.add_item_from_child_list(shopping_list.list_items.last) # for the sake of realism
          aggregate_list.add_item_from_child_list(second_list.list_items.first)
        end

        it 'updates the regular list item' do
          update_item
          expect(list_item.reload.attributes).to include(
                                                   'quantity' => 5,
                                                   'notes'    => 'To make locks',
                                                 )
        end

        it 'updates the item on the aggregate list' do
          update_item
          expect(aggregate_list.list_items.first.attributes).to include(
                                                                  'description' => list_item.description,
                                                                  'quantity'    => 7,
                                                                  'notes'       => 'To make locks',
                                                                )
        end

        it 'updates the regular list' do
          t = Time.zone.now + 3.days
          Timecop.freeze(t) do
            update_item
            # use `be_within` even though the time will be set to the time Timecop
            # has frozen because Rails (Postgres?) sets the last three digits of
            # the timestamp to 0, which was breaking stuff in CI (but somehow not
            # in dev).
            expect(shopping_list.reload.updated_at).to be_within(0.005.seconds).of(t)
          end
        end

        it 'returns the aggregate list item and the regular list item', :aggregate_failures do
          update_item

          # The serialization isn't as simple as .to_json and it makes it hard to determine if the JSON
          # string is correct as some attributes are out of order and the timestamps are serialized
          # differently. Here we grab the individual items and then we'll filter out the timestamps to
          # verify them.
          aggregate_list_item_actual, regular_list_item_actual = JSON.parse(response.body).map do |item_attrs|
            item_attrs.except('created_at', 'updated_at')
          end

          aggregate_list_item_expected = aggregate_list.list_items.first.attributes.except('created_at', 'updated_at')
          regular_list_item_expected   = shopping_list.list_items.first.attributes.except('created_at', 'updated_at')

          expect(aggregate_list_item_actual).to eq(aggregate_list_item_expected)
          expect(regular_list_item_actual).to eq(regular_list_item_expected)
        end

        it 'returns status 200' do
          update_item
          expect(response.status).to eq 200
        end
      end

      context 'when the shopping list belongs to a different user' do
        let(:user)      { create(:user) }
        let(:params)    { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }
        let(:list_item) { create(:shopping_list_item, description: 'Corundum ingot', notes: nil) }

        it 'does not updatte the list item' do
          update_item
          expect(list_item.quantity).to eq 1
          expect(list_item.notes).to be nil
        end

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
        let(:game)      { create(:game_with_shopping_lists) }
        let(:user)      { game.user }
        let(:list_item) { double("this item doesn't exist", id: 8942) }
        let(:params)    { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

        it 'returns 404' do
          update_item
          expect(response.status).to eq 404
        end

        it 'returns no body' do
          update_item
          expect(response.body).to be_empty
        end
      end

      context 'when the shopping list is an aggregate list' do
        let(:game)          { create(:game_with_shopping_lists, user: user) }
        let(:shopping_list) { game.aggregate_shopping_list }
        let(:list_item)     { shopping_list.list_items.create!(description: 'Corundum Ingot', list: shopping_list) }
        let(:params)        { { shopping_list_item: { 'quantity': 5, notes: 'To make locks' } } }

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
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually update list items on an aggregate shopping list'] })
        end
      end

      context 'when the params are invalid' do
        let(:list_item) { shopping_list.list_items.create!(description: 'Corundum ingot') }
        let(:params)    { { shopping_list_item: { description: 'Corundum ingot', quantity: 'foooo', notes: 'To make locks' } } }

        before do
          aggregate_list.add_item_from_child_list(list_item)
        end

        it 'does not update the aggregate list', :aggregate_failures do
          update_item
          expect(aggregate_list.list_items.first.quantity).to eq 1
          expect(aggregate_list.list_items.first.notes).to be nil
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
      let(:user)      { create(:user) }
      let(:params)    { { shopping_list_item: { description: 'Corundum ingot', quantity: 4, notes: 'To make locks' } } }
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

  describe 'PUT /shopping_list_items/:id' do
    subject(:update_item) do
      put "/shopping_list_items/#{list_item.id}", params: params.to_json, headers: headers
    end

    let!(:aggregate_list) { create(:aggregate_shopping_list) }
    let!(:shopping_list) { create(:shopping_list_with_list_items, game: aggregate_list.game) }

    context 'when authenticated' do
      let!(:user) { aggregate_list.user }

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
        let(:params)    { { shopping_list_item: { quantity: 5, notes: 'To make locks' } } }
        let(:game)      { aggregate_list.game }
        let(:list_item) { shopping_list.list_items.first }

        before do
          second_list = create(:shopping_list, game: game, aggregate_list: aggregate_list)
          second_list.list_items.create!(description: list_item.description, quantity: 2)
          aggregate_list.add_item_from_child_list(shopping_list.list_items.first)
          aggregate_list.add_item_from_child_list(shopping_list.list_items.last) # for the sake of realism
          aggregate_list.add_item_from_child_list(second_list.list_items.first)
        end

        it 'updates the regular list item' do
          update_item
          expect(list_item.reload.attributes).to include(
                                                   'quantity' => 5,
                                                   'notes'    => 'To make locks',
                                                 )
        end

        it 'updates the item on the aggregate list' do
          update_item
          expect(aggregate_list.list_items.first.attributes).to include(
                                                                  'description' => list_item.description,
                                                                  'quantity'    => 7,
                                                                  'notes'       => 'To make locks',
                                                                )
        end

        it 'updates the regular list' do
          t = Time.zone.now + 3.days
          Timecop.freeze(t) do
            update_item
            # use `be_within` even though the time will be set to the time Timecop
            # has frozen because Rails (Postgres?) sets the last three digits of
            # the timestamp to 0, which was breaking stuff in CI (but somehow not
            # in dev).
            expect(shopping_list.reload.updated_at).to be_within(0.005.seconds).of(t)
          end
        end

        it 'returns the aggregate list item and the regular list item', :aggregate_failures do
          update_item

          # The serialization isn't as simple as .to_json and it makes it hard to determine if the JSON
          # string is correct as some attributes are out of order and the timestamps are serialized
          # differently. Here we grab the individual items and then we'll filter out the timestamps to
          # verify them.
          aggregate_list_item_actual, regular_list_item_actual = JSON.parse(response.body).map do |item_attrs|
            item_attrs.except('created_at', 'updated_at')
          end

          aggregate_list_item_expected = aggregate_list.list_items.first.attributes.except('created_at', 'updated_at')
          regular_list_item_expected   = shopping_list.list_items.first.attributes.except('created_at', 'updated_at')

          expect(aggregate_list_item_actual).to eq(aggregate_list_item_expected)
          expect(regular_list_item_actual).to eq(regular_list_item_expected)
        end

        it 'returns status 200' do
          update_item
          expect(response.status).to eq 200
        end
      end

      context 'when the shopping list belongs to a different user' do
        let(:user)      { create(:user) }
        let(:params)    { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }
        let(:list_item) { create(:shopping_list_item, description: 'Corundum ingot', notes: nil) }

        it 'does not updatte the list item' do
          update_item
          expect(list_item.quantity).to eq 1
          expect(list_item.notes).to be nil
        end

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
        let(:game)      { create(:game_with_shopping_lists) }
        let(:user)      { game.user }
        let(:list_item) { double("this item doesn't exist", id: 8942) }
        let(:params)    { { shopping_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

        it 'returns 404' do
          update_item
          expect(response.status).to eq 404
        end

        it 'returns no body' do
          update_item
          expect(response.body).to be_empty
        end
      end

      context 'when the shopping list is an aggregate list' do
        let(:game)          { create(:game_with_shopping_lists, user: user) }
        let(:shopping_list) { game.aggregate_shopping_list }
        let(:list_item)     { shopping_list.list_items.create!(description: 'Corundum Ingot', list: shopping_list) }

        let(:params) { { shopping_list_item: { 'quantity': 5, notes: 'To make locks' } } }

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
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually update list items on an aggregate shopping list'] })
        end
      end

      context 'when the params are invalid' do
        let(:list_item) { shopping_list.list_items.create!(description: 'Corundum ingot') }
        let(:params)    { { shopping_list_item: { description: 'Corundum ingot', quantity: 'foooo', notes: 'To make locks' } } }

        before do
          aggregate_list.add_item_from_child_list(list_item)
        end

        it 'does not update the aggregate list', :aggregate_failures do
          update_item
          expect(aggregate_list.list_items.first.quantity).to eq 1
          expect(aggregate_list.list_items.first.notes).to be nil
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
      let(:user)      { create(:user) }
      let(:params)    { { shopping_list_item: { description: 'Corundum ingot', quantity: 4, notes: 'To make locks' } } }
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

  describe 'DELETE /shopping_list_items/:id' do
    subject(:destroy_item) { delete "/shopping_list_items/#{list_item.id}", headers: headers }

    context 'when authenticated' do
      let!(:aggregate_list) { create(:aggregate_shopping_list, game: game) }
      let!(:shopping_list)  { create(:shopping_list, game: game, aggregate_list: aggregate_list) }

      let(:game)      { create(:game) }
      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }
      let(:validation_data) do
        {
          'exp'   => (Time.zone.now + 1.year).to_i,
          'email' => game.user.email,
          'name'  => game.user.name,
        }
      end

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when all goes well' do
        let(:user)      { list_item.user }
        let(:list_item) { create(:shopping_list_item, list: shopping_list, quantity: 3, notes: 'foo') }

        before do
          aggregate_list.add_item_from_child_list(list_item)
        end

        context 'when the quantity on the regular list equals that on the aggregate list' do
          it 'destroys the item on the regular list' do
            destroy_item
            expect { ShoppingListItem.find(list_item.id) }
              .to raise_error ActiveRecord::RecordNotFound
          end

          it 'destroys the item on the aggregate list' do
            destroy_item
            expect(aggregate_list.list_items).to be_empty
          end

          it 'returns an empty response' do
            destroy_item
            expect(response.body).to be_empty
          end

          it 'returns status 204' do
            destroy_item
            expect(response.status).to eq 204
          end
        end

        context 'when the quantity on the aggregate list exceeds that on the regular list' do
          let(:second_list) { create(:shopping_list, game: game) }
          let(:second_item) { create(:shopping_list_item, list: second_list, description: list_item.description, quantity: 2, notes: 'bar') }

          before do
            aggregate_list.add_item_from_child_list(second_item)
          end

          it 'destroys the item on the regular list' do
            destroy_item
            expect { ShoppingListItem.find(list_item.id) }
              .to raise_error ActiveRecord::RecordNotFound
          end

          it 'updates the quantity of the item on the aggregate list' do
            destroy_item
            expect(aggregate_list.list_items.first.quantity).to eq 2
          end

          it 'updates the notes of the item on the aggregate list', :aggregate_failures do
            destroy_item
            expect(aggregate_list.list_items.first.notes).to match /bar/
            expect(aggregate_list.list_items.first.notes).not_to match /foo/
          end
        end
      end

      context "when the specified list item doesn't exist" do
        let(:list_item) { double("this doesn't exist", id: 772) }

        it 'returns status 404' do
          destroy_item
          expect(response.status).to eq 404
        end

        it "doesn't return any error messages" do
          destroy_item
          expect(response.body).to be_empty
        end
      end

      context "when the specified list item doesn't belong to the authenticated user" do
        let(:list_item) { create(:shopping_list_item) }

        it 'returns status 404' do
          destroy_item
          expect(response.status).to eq 404
        end

        it 'returns an empty response body' do
          destroy_item
          expect(response.body).to be_empty
        end
      end

      context 'when the specified list item is on an aggregate list' do
        let(:list_item) { create(:shopping_list_item, list: aggregate_list) }

        it 'returns status 405' do
          destroy_item
          expect(response.status).to eq 405
        end

        it 'returns a helpful error message' do
          destroy_item
          expect(JSON.parse(response.body)).to eq({ 'errors' => ['Cannot manually delete list item from aggregate shopping list'] })
        end
      end
    end

    context 'when unauthenticated' do
      let(:list_item) { create(:shopping_list_item) }

      it 'returns a 401' do
        destroy_item
        expect(response.status).to eq 401
      end

      it 'indicates the request was unauthenticated' do
        destroy_item
        expect(JSON.parse(response.body)).to eq({ 'errors' => ['Google OAuth token validation failed'] })
      end
    end
  end
end
