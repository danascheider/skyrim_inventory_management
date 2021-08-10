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
            context "when unit weight isn't set" do
              it 'creates a new item on the requested list'

              it 'updates the item on the aggregate list'

              it 'returns status 201'

              it 'returns the aggregate list item and the regular list item'
            end

            context 'when unit weight is set' do
              it 'creates a new item on the requested list'

              it 'updates the item on the aggregate list'

              it 'updates the unit weight of the other regular-list item'

              it 'returns status 201'

              it 'returns all items that were created or updated'
            end
          end
        end

        context 'when there is an existing matching item on the same list' do
          context "when unit weight isn't updated" do
            it 'combines the requested item with the existing item'

            it 'updates the item on the aggregate list'

            it "doesn't change matching items on other regular lists"

            it 'returns status 200'

            it 'returns the requested item and the aggregate list item'
          end

          context 'when unit weight is updated' do
            it 'combines the requested item with the existing item'

            it 'updates the item on the aggregate list'

            it 'updates matching items on other regular lists'

            it 'returns status 200'

            it 'returns all items that have been updated'
          end
        end
      end
    end
  end
end
