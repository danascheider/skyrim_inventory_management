# frozen_string_literal: true

require 'rails_helper'
require 'service/created_result'
require 'service/not_found_result'
require 'service/unprocessable_entity_result'
require 'service/method_not_allowed_result'
require 'service/internal_server_error_result'
require 'service/ok_result'

RSpec.describe ShoppingListItemsController::CreateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, shopping_list.id, params).perform }

    let(:user) { create(:user) }
    let(:game) { create(:game, user: user) }

    context 'when all goes well' do
      let!(:aggregate_list) { create(:aggregate_shopping_list, game: game) }
      let!(:shopping_list)  { create(:shopping_list, game: game, aggregate_list: aggregate_list) }
      let(:params)          { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      before do
        user_lists = user.shopping_lists
        allow(user).to receive(:shopping_lists).and_return(user_lists)
        allow(user_lists).to receive(:find).and_return(shopping_list)
        allow(shopping_list).to receive(:aggregate_list).and_return(aggregate_list)
      end

      context 'when there is no matching item on the regular list' do
        before do
          allow(aggregate_list).to receive(:add_item_from_child_list).and_call_original
        end

        it 'adds a list item to the given list' do
          expect { perform }
            .to change(shopping_list.list_items, :count).from(0).to(1)
        end

        it 'assigns the correct values' do
          params_with_string_keys = {}

          params.each {|key, value| params_with_string_keys[key.to_s] = value }

          perform
          expect(shopping_list.list_items.last.attributes).to include(**params_with_string_keys)
        end

        it 'updates the aggregate list' do
          perform
          expect(aggregate_list).to have_received(:add_item_from_child_list).with(shopping_list.list_items.last)
        end

        it 'updates the list model itself' do
          t = Time.zone.now + 3.days
          Timecop.freeze(t) do
            perform
            expect(shopping_list.reload.updated_at).to be_within(0.005.seconds).of(t)
          end
        end

        it 'updates the game' do
          t = Time.zone.now + 3.days
          Timecop.freeze(t) do
            perform
            expect(game.reload.updated_at).to be_within(0.005.seconds).of(t)
          end
        end

        it 'returns a Service::CreatedResult' do
          expect(perform).to be_a(Service::CreatedResult)
        end

        it 'returns both the created list item and aggregate list item' do
          expect(perform.resource).to eq([aggregate_list.list_items.last, shopping_list.list_items.last])
        end

        context 'when there is a matching item on the aggregate list' do
          context 'when unit weight is specified' do
            let(:params) { { description: 'Necklace', quantity: 2, unit_weight: 1, notes: 'Hello world' } }

            let(:other_list)              { create(:shopping_list, game: aggregate_list.game, aggregate_list: aggregate_list) }
            let!(:item_on_other_list)     { create(:shopping_list_item, list: other_list, unit_weight: 2, description: 'Necklace', quantity: 1) }
            let!(:item_on_aggregate_list) { create(:shopping_list_item, list: aggregate_list, unit_weight: 2, description: 'Necklace', quantity: 1) }

            before do
              # Make sure that the response only returns matching list items belonging to
              # the same game
              other_list.list_items.create!(description: 'Dwarven metal ingot', quantity: 1)
              create(:shopping_list_item, description: 'Necklace', quantity: 1)
            end

            it 'updates the unit weight on existing matching list items', :aggregate_failures do
              perform
              expect(item_on_other_list.reload.unit_weight).to eq 1
              expect(item_on_aggregate_list.reload.unit_weight).to eq 1
            end

            it 'returns all the list items that were updated' do
              expect(perform.resource.sort).to eq [item_on_aggregate_list, item_on_other_list, shopping_list.list_items.last].sort
            end
          end

          context 'when unit weight is not specified' do
            let(:other_list)              { create(:shopping_list, game: aggregate_list.game, aggregate_list: aggregate_list) }
            let!(:item_on_other_list)     { create(:shopping_list_item, list: other_list, unit_weight: 2, description: 'Necklace', quantity: 1) }
            let!(:item_on_aggregate_list) { create(:shopping_list_item, list: aggregate_list, unit_weight: 2, description: 'Necklace', quantity: 1) }

            it 'returns the regular list item and the aggregate list item' do
              expect(perform.resource).to eq [item_on_aggregate_list, shopping_list.list_items.last]
            end
          end
        end
      end

      context 'when there is a matching item on the regular list' do
        let!(:existing_item) { create(:shopping_list_item, list: shopping_list, description: 'Necklace', quantity: 2, unit_weight: 0.5, notes: 'to enchant') }

        before do
          aggregate_list.add_item_from_child_list(existing_item)
          allow(aggregate_list).to receive(:update_item_from_child_list).and_call_original
        end

        it "doesn't create a new item on the regular list" do
          expect { perform }
            .not_to change(shopping_list.list_items, :count)
        end

        it "doesn't create a new item on the aggregate list" do
          expect { perform }
            .not_to change(aggregate_list.list_items, :count)
        end

        it 'updates the list itself' do
          t = Time.zone.now + 3.days
          Timecop.freeze(t) do
            perform
            expect(shopping_list.reload.updated_at).to be_within(0.005.seconds).of(t)
          end
        end

        it 'updates the game' do
          t = Time.zone.now + 3.days
          Timecop.freeze(t) do
            perform
            expect(game.reload.updated_at).to be_within(0.005.seconds).of(t)
          end
        end

        it 'updates the aggregate list correctly' do
          perform
          expect(aggregate_list).to have_received(:update_item_from_child_list).with('Necklace', 2, nil, nil, 'Hello world')
        end

        context 'when no unit weight is specified' do
          it 'leaves unit weight as-is for the existing item' do
            perform
            expect(existing_item.reload.unit_weight).to eq 0.5
          end

          context 'when there is a matching item on another list' do
            let(:other_list)          { create(:shopping_list, game: aggregate_list.game, aggregate_list: aggregate_list) }
            let!(:other_item)         { create(:shopping_list_item, list: other_list, description: 'Necklace', quantity: 1, unit_weight: 0.5) }
            let(:aggregate_list_item) { aggregate_list.list_items.find_by(description: 'Necklace') }

            before do
              aggregate_list.add_item_from_child_list(other_item)
            end

            it 'leaves unit weight as-is for the item on the other list' do
              perform
              expect(other_item.reload.unit_weight).to eq 0.5
            end

            it 'returns the regular list item and the aggregate list item' do
              perform
              expect(perform.resource).to eq [aggregate_list_item, shopping_list.list_items.last]
            end
          end
        end

        context 'when a unit weight is specified' do
          let(:params) { { description: 'Necklace', quantity: 2, unit_weight: 1, notes: 'Hello world' } }

          it 'updates the unit weight on the list item' do
            perform
            expect(existing_item.reload.unit_weight).to eq 1
          end

          it 'updates the unit weight on the aggregate list item' do
            perform
            expect(aggregate_list.list_items.last.unit_weight).to eq 1
          end

          context 'when there is a matching item on another list as well' do
            let(:other_list)  { create(:shopping_list, game: aggregate_list.game, aggregate_list: aggregate_list) }
            let!(:other_item) { create(:shopping_list_item, unit_weight: 0.5, quantity: 1, description: 'Necklace', list: other_list) }

            before do
              aggregate_list.add_item_from_child_list(other_item)
            end

            it 'updates the unit weight on the other list item' do
              perform
              expect(other_item.reload.unit_weight).to eq 1
            end

            it 'returns all the items that were updated' do
              expect(perform.resource.sort).to eq [aggregate_list.list_items.last, existing_item, other_item].sort
            end
          end
        end
      end
    end

    context 'when the list does not exist' do
      let(:shopping_list) { double(id: 348) }
      let(:params)        { { 'description' => 'Necklace', 'quantity' => 2, 'notes' => 'Hello world' } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any data", :aggregate_failures do
        expect(perform.errors).to be_blank
        expect(perform.resource).to be_blank
      end
    end

    context 'when the list does not belong to the user' do
      let!(:shopping_list) { create(:shopping_list) }
      let(:params)         { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any data", :aggregate_failures do
        expect(perform.errors).to be_blank
        expect(perform.resource).to be_blank
      end
    end

    context 'when there is a duplicate description' do
      let!(:aggregate_list) { create(:aggregate_shopping_list, game: game) }
      let!(:shopping_list)  { create(:shopping_list, game: game, aggregate_list: aggregate_list) }
      let(:params)          { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      before do
        shopping_list.list_items.create!(description: 'Necklace', quantity: 1, notes: 'To enchant')
        aggregate_list.add_item_from_child_list(shopping_list.list_items.last)
      end

      it 'combines the item with an existing one' do
        expect { perform }
          .not_to change(shopping_list.list_items, :count)
      end

      it 'updates the shopping list' do
        t = Time.zone.now + 3.days
        Timecop.freeze(t) do
          perform
          expect(shopping_list.reload.updated_at).to be_within(0.005.seconds).of(t)
        end
      end

      it 'updates the game' do
        t = Time.zone.now + 3.days
        Timecop.freeze(t) do
          perform
          expect(game.reload.updated_at).to be_within(0.005.seconds).of(t)
        end
      end

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the list items' do
        expect(perform.resource).to eq([aggregate_list.list_items.last, shopping_list.list_items.last])
      end
    end

    context 'when the params are invalid' do
      let!(:shopping_list) { create(:shopping_list, game: game) }
      let(:params)         { { description: 'Necklace', quantity: -1, notes: 'invalid quantity' } }

      it 'returns a Service::UnprocessableEntityResult' do
        expect(perform).to be_a(Service::UnprocessableEntityResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Quantity must be greater than 0'])
      end
    end

    context 'when the list is an aggregate list' do
      let!(:shopping_list) { create(:aggregate_shopping_list, game: game) }
      let(:params)         { { description: 'Necklace', quantity: 1, notes: 'this should not work' } }

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a(Service::MethodNotAllowedResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Cannot manually manage items on an aggregate shopping list'])
      end
    end

    context 'when something unexpected goes wrong' do
      let!(:shopping_list) { create(:shopping_list, game: game) }
      let(:params)         { { description: 'Necklace', quantity: 1, notes: 'hello world' } }

      before do
        allow_any_instance_of(ShoppingListItem).to receive(:save!).and_raise(StandardError, 'Something went horribly wrong')
      end

      it 'returns a 500 response' do
        expect(perform).to be_a(Service::InternalServerErrorResult)
      end

      it 'sets the error message' do
        expect(perform.errors).to eq(['Something went horribly wrong'])
      end
    end
  end
end
