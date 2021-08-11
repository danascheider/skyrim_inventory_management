# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'InventoryListItems', type: :request do
  let(:headers) do
    {
      'Content-Type'  => 'application/json',
      'Authorization' => 'Bearer xxxxxxxx',
    }
  end

  describe 'POST /inventory_lists/:inventory_list_id/inventory_list_items' do
    subject(:create_item) do
      post "/inventory_lists/#{inventory_list.id}/inventory_list_items",
           params:  params.to_json,
           headers: headers
    end

    let!(:aggregate_list) { create(:aggregate_inventory_list) }
    let!(:inventory_list) { create(:inventory_list, aggregate_list: aggregate_list, game: aggregate_list.game) }

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
        let(:params) { { inventory_list_item: { description: 'Corundum ingot', quantity: 5, notes: 'To make locks' } } }

        context 'when there is no existing matching item on the same list' do
          context 'when there is no existing matching item on any list' do
            it 'creates a new item on the requested list' do
              expect { create_item }
                .to change(inventory_list.list_items, :count).from(0).to(1)
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
              expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list.list_items.last, inventory_list.list_items.last].to_json))
            end
          end

          context 'when there is an existing matching item on another list' do
            let(:other_list)  { create(:inventory_list, game: aggregate_list.game) }
            let!(:other_item) { create(:inventory_list_item, list: other_list, description: 'Corundum ingot', quantity: 2) }

            before do
              aggregate_list.add_item_from_child_list(other_item)
            end

            context "when unit weight isn't set" do
              let(:params) { { inventory_list_item: { description: 'Corundum ingot', quantity: 5 } } }

              it 'creates a new item on the requested list' do
                expect { create_item }
                  .to change(inventory_list.list_items, :count).from(0).to(1)
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
                expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list.list_items.first, inventory_list.list_items.first].to_json))
              end
            end

            context 'when unit weight is set' do
              let(:params) { { inventory_list_item: { description: 'Corundum ingot', quantity: 5, unit_weight: 1 } } }

              it 'creates a new item on the requested list' do
                expect { create_item }
                  .to change(inventory_list.list_items, :count).from(0).to(1)
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
                expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list.list_items.first, other_item.reload, inventory_list.list_items.first].to_json))
              end
            end
          end
        end

        context 'when there is an existing matching item on the same list' do
          let(:other_list) { create(:inventory_list, game: aggregate_list.game, aggregate_list: aggregate_list) }
          let!(:other_item) { create(:inventory_list_item, list: other_list, description: 'Corundum ingot', quantity: 2) }
          let!(:list_item)  { create(:inventory_list_item, list: inventory_list, description: 'Corundum ingot', quantity: 3) }

          before do
            aggregate_list.add_item_from_child_list(other_item)
            aggregate_list.add_item_from_child_list(list_item)
          end

          context "when unit weight isn't updated" do
            it "doesn't create a new item" do
              expect { create_item }
                .not_to change(InventoryListItem, :count)
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
            let(:params) { { inventory_list_item: { description: 'Corundum ingot', quantity: 2, unit_weight: 1 } } }

            it "doesn't create a new list item" do
              expect { create_item }
                .not_to change(InventoryListItem, :count)
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
        let(:inventory_list) { double(id: 23_498) }

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
        let(:inventory_list) { create(:inventory_list) }
        let(:params)         { { inventory_list_item: { description: 'Corundum ingot', quantity: 5 } } }

        it "doesn't create the list item" do
          expect { create_item }
            .not_to change(InventoryListItem, :count)
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
        let(:params) { { inventory_list_item: { description: 'Corundum ingot', quantity: -2 } } }

        it "doesn't create the item" do
          expect { create_item }
            .not_to change(InventoryListItem, :count)
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
        let(:inventory_list) { aggregate_list }
        let(:params)         { { inventory_list_item: { description: 'Corundum ingot', quantity: 4 } } }

        it "doesn't create an item" do
          expect { create_item }
            .not_to change(InventoryListItem, :count)
        end

        it 'returns status 405' do
          create_item
          expect(response.status).to eq 405
        end

        it 'returns the error' do
          create_item
          expect(JSON.parse(response.body))
            .to eq({ 'errors' => ['Cannot manually manage items on an aggregate inventory list'] })
        end
      end

      context 'when something unexpected goes wrong' do
        let(:params) { { inventory_list_item: { description: 'Corundum ingot', quantity: 4 } } }

        before do
          allow(InventoryList).to receive(:find).and_raise(StandardError.new('Something went horribly wrong'))
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

  describe 'PATCH /inventory_list_items/:id' do
    subject(:update_item) { patch "/inventory_list_items/#{list_item.id}", headers: headers, params: params.to_json }

    let(:game)            { create(:game) }
    let!(:aggregate_list) { create(:aggregate_inventory_list, game: game) }
    let!(:inventory_list) { create(:inventory_list, game: game, aggregate_list: aggregate_list) }

    context 'when authenticated' do
      let!(:user)     { game.user }
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
        context 'when there is no matching item on another list' do
          let!(:list_item)          { create(:inventory_list_item, list: inventory_list, description: 'Dwarven metal ingot', quantity: 5) }
          let(:aggregate_list_item) { aggregate_list.list_items.first }
          let(:params)              { { inventory_list_item: { description: 'Dwarven metal ingot', quantity: 10 } } }

          before do
            aggregate_list.add_item_from_child_list(list_item)
          end

          it 'updates the list item' do
            update_item
            expect(list_item.reload.quantity).to eq 10
          end

          it 'updates the aggregate list item' do
            update_item
            expect(aggregate_list_item.quantity).to eq 10
          end

          it 'returns status 200' do
            update_item
            expect(response.status).to eq 200
          end

          it 'returns the regular list item and the aggregate list item' do
            update_item
            expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list_item, list_item.reload].to_json))
          end
        end

        context 'when there is a matching item on another list' do
          let!(:list_item)          { create(:inventory_list_item, list: inventory_list) }
          let!(:other_list)         { create(:inventory_list, game: game, aggregate_list: aggregate_list) }
          let!(:other_item)         { create(:inventory_list_item, list: other_list, description: list_item.description, quantity: 4) }
          let(:aggregate_list_item) { aggregate_list.list_items.first }

          before do
            aggregate_list.add_item_from_child_list(list_item)
            aggregate_list.add_item_from_child_list(other_item)
          end

          context 'when unit_weight is not changed' do
            let(:params) { { inventory_list_item: { quantity: 10 } } }

            it 'updates the list item' do
              update_item
              expect(list_item.reload.quantity).to eq 10
            end

            it 'updates the aggregate list item' do
              update_item
              expect(aggregate_list_item.quantity).to eq 14
            end

            it 'returns status 200' do
              update_item
              expect(response.status).to eq 200
            end

            it 'returns the list item and the aggregate list item' do
              update_item
              expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list_item, list_item.reload].to_json))
            end
          end

          context 'when unit_weight is changed' do
            let(:params) { { inventory_list_item: { quantity: 10, unit_weight: 2 } } }

            it 'updates the list item', :aggregate_failures do
              update_item
              expect(list_item.reload.quantity).to eq 10
              expect(list_item.unit_weight).to eq 2
            end

            it 'updates the aggregate list item', :aggregate_failures do
              update_item
              expect(aggregate_list_item.quantity).to eq 14
              expect(aggregate_list_item.unit_weight).to eq 2
            end

            it 'updates only the unit weight of the other list item', :aggregate_failures do
              update_item
              expect(other_item.reload.quantity).to eq 4
              expect(other_item.unit_weight).to eq 2
            end

            it 'returns status 200' do
              update_item
              expect(response.status).to eq 200
            end

            it 'returns all items that were changed' do
              update_item
              expect(JSON.parse(response.body)).to eq(JSON.parse([aggregate_list_item, other_item.reload, list_item.reload].to_json))
            end
          end
        end
      end

      context "when the inventory list item doesn't exist" do
        let(:list_item) { double(id: 234_567) }
        let(:params)    { { quantity: 4, unit_weight: 0.3 } }

        it 'returns status 404' do
          update_item
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          update_item
          expect(response.body).to be_blank
        end
      end

      context "when the inventory list item doesn't belong to the authenticated user" do
        let(:list_item) { create(:inventory_list_item) }
        let(:params)    { { notes: 'Hello world' } }

        it 'returns status 404' do
          update_item
          expect(response.status).to eq 404
        end

        it "doesn't return any data" do
          update_item
          expect(response.body).to be_blank
        end
      end
    end
  end
end
