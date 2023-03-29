# frozen_string_literal: true

require 'rails_helper'
require 'service/created_result'
require 'service/ok_result'
require 'service/not_found_result'
require 'service/method_not_allowed_result'
require 'service/internal_server_error_result'

RSpec.describe ShoppingListItemsController::CreateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, shopping_list.id, params).perform }

    let(:user) { create(:user) }
    let(:game) { create(:game, user:) }
    let!(:aggregate_list) { create(:aggregate_shopping_list, game:) }
    let!(:shopping_list) { create(:shopping_list, game:, aggregate_list:) }

    context 'when all goes well' do
      let(:params) { { description: 'Necklace', quantity: 2, notes: 'Hello world' } }

      context 'when there is no existing matching item on the same list' do
        context 'when there is no existing matching item on any list' do
          it 'creates a new item on the list' do
            expect { perform }
              .to change(shopping_list.list_items, :count).from(0).to(1)
          end

          it 'creates a new item on the aggregate list' do
            expect { perform }
              .to change(aggregate_list.list_items, :count).from(0).to(1)
          end

          it 'returns a Service::CreatedResult' do
            expect(perform).to be_a(Service::CreatedResult)
          end

          it 'sets the resource to all the changed shopping lists' do
            expect(perform.resource).to eq [aggregate_list, shopping_list]
          end
        end

        context 'when there is an existing matching item on another list' do
          let(:other_list) { create(:shopping_list, game: aggregate_list.game, aggregate_list:) }
          let!(:other_item) { create(:shopping_list_item, list: other_list, description: 'Necklace', unit_weight: 1, quantity: 1) }

          before do
            # This should not be included in the resource body
            create(:shopping_list, game:)

            aggregate_list.add_item_from_child_list(other_item)
          end

          context 'when the unit_weight is not set' do
            it 'creates a new item on the list' do
              expect { perform }
                .to change(shopping_list.list_items, :count).from(0).to eq 1
            end

            it 'sets the unit weight on the new item' do
              perform
              expect(shopping_list.list_items.unscoped.last.unit_weight).to eq 1
            end

            it 'updates the item on the aggregate list', :aggregate_failures do
              perform
              expect(aggregate_list.list_items.first.unit_weight).to eq 1
              expect(aggregate_list.list_items.first.quantity).to eq 3
              expect(aggregate_list.list_items.first.notes).to eq 'Hello world'
            end

            it 'returns a Service::CreatedResult' do
              expect(perform).to be_a(Service::CreatedResult)
            end

            it 'sets all the changed shopping lists as the resource' do
              expect(perform.resource).to eq([aggregate_list, shopping_list])
            end
          end

          context 'when the unit_weight is set' do
            let(:params) { { description: 'Necklace', quantity: 2, unit_weight: 0.5, notes: 'Hello world' } }

            it 'creates a new item on the list' do
              expect { perform }
                .to change(shopping_list.list_items, :count).from(0).to(1)
            end

            it 'updates the item on the aggregate list', :aggregate_failures do
              perform
              expect(aggregate_list.list_items.first.quantity).to eq 3
              expect(aggregate_list.list_items.first.notes).to eq 'Hello world'
              expect(aggregate_list.list_items.first.unit_weight).to eq 0.5
            end

            it "updates the other item's unit_weight", :aggregate_failures do
              perform
              expect(other_item.reload.quantity).to eq 1
              expect(other_item.reload.unit_weight).to eq 0.5
            end

            it 'returns a Service::CreatedResult' do
              expect(perform).to be_a(Service::CreatedResult)
            end

            it 'sets all the changed shopping lists as the resource' do
              expect(perform.resource).to eq([aggregate_list, other_list, shopping_list])
            end
          end
        end
      end

      context 'when there is an existing matching item on the same list' do
        let(:other_list) { create(:shopping_list, game:) }
        let!(:other_item) { create(:shopping_list_item, list: other_list, description: 'Necklace', quantity: 2) }
        let!(:list_item) { create(:shopping_list_item, list: shopping_list, description: 'Necklace', quantity: 1) }

        before do
          # This should not be included in the resource body
          create(:shopping_list, game:)

          aggregate_list.add_item_from_child_list(other_item)
          aggregate_list.add_item_from_child_list(list_item)
        end

        context "when unit weight isn't updated" do
          let(:params) { { description: 'Necklace', quantity: 2 } }

          it "doesn't create a new item" do
            expect { perform }
              .not_to change(ShoppingListItem, :count)
          end

          it 'combines with the existing item' do
            perform
            expect(list_item.reload.quantity).to eq 3
          end

          it 'updates the item on the aggregate list' do
            perform
            expect(aggregate_list.list_items.first.quantity).to eq 5
          end

          it 'returns a Service::OKResult' do
            expect(perform).to be_a(Service::OKResult)
          end

          it 'sets all the changed shopping lists as the resource' do
            expect(perform.resource).to eq([aggregate_list, shopping_list])
          end
        end

        context 'when unit weight is updated' do
          let(:params) { { description: 'Necklace', quantity: 2, unit_weight: 0.5 } }

          it "doesn't create a new list item" do
            expect { perform }
              .not_to change(ShoppingListItem, :count)
          end

          it 'combines the items', :aggregate_failures do
            perform
            expect(list_item.reload.quantity).to eq 3
            expect(list_item.unit_weight).to eq 0.5
          end

          it 'updates the item on the aggregate list', :aggregate_failures do
            perform
            expect(aggregate_list.list_items.first.quantity).to eq 5
            expect(aggregate_list.list_items.first.unit_weight).to eq 0.5
          end

          it 'updates only the unit_weight on the other item', :aggregate_failures do
            perform
            expect(other_item.reload.unit_weight).to eq 0.5
            expect(other_item.quantity).to eq 2
          end

          it 'returns a Service::OKResult' do
            expect(perform).to be_a(Service::OKResult)
          end

          it 'sets all the changed shopping lists as the resource' do
            expect(perform.resource).to eq(game.shopping_lists.where(id: [aggregate_list.id, shopping_list.id, other_list.id]))
          end
        end
      end
    end

    context "when the list doesn't exist" do
      let(:params) { { description: 'Necklace', quantity: 4, unit_weight: 0.5 } }
      let(:shopping_list) { double(id: 234_980) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any data", :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end

    context 'when the list belongs to another user' do
      let(:params) { { description: 'Necklace', quantity: 4, unit_weight: 0.5 } }
      let!(:shopping_list) { create(:shopping_list) }

      it "doesn't create a list item" do
        expect { perform }
          .not_to change(ShoppingListItem, :count)
      end

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any data", :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end

    context 'when the params are invalid' do
      let(:params) { { description: 'Necklace', quantity: -2 } }

      it 'returns a Service::UnprocessableEntityResult' do
        expect(perform).to be_a(Service::UnprocessableEntityResult)
      end

      it 'returns the error array' do
        expect(perform.errors).to eq(['Quantity must be greater than 0'])
      end
    end

    context 'when the list is an aggregate list' do
      let(:shopping_list) { aggregate_list }
      let!(:params) { { description: 'Necklace', quantity: 2 } }

      it "doesn't create an item" do
        expect { perform }
          .not_to change(ShoppingListItem, :count)
      end

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a(Service::MethodNotAllowedResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq ['Cannot manually manage items on an aggregate shopping list']
      end
    end

    context 'when something unexpected goes wrong' do
      let!(:params) { { description: 'Necklace', quantity: 2 } }

      before do
        allow(ShoppingList).to receive(:find).and_raise(StandardError.new('Something went horribly wrong'))
      end

      it 'returns a Service::InternalServerErrorResponse' do
        expect(perform).to be_a(Service::InternalServerErrorResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq ['Something went horribly wrong']
      end
    end
  end
end
