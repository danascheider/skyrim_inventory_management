# frozen_string_literal: true

require 'rails_helper'
require 'service/method_not_allowed_result'
require 'service/not_found_result'
require 'service/ok_result'

RSpec.describe ShoppingListsController::DestroyService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, shopping_list.id).perform }

    let(:user) { create(:user) }

    context 'when all goes well' do
      let!(:shopping_list) { create(:shopping_list_with_list_items, game:) }
      let(:game) { create(:game, user:) }

      context 'when the game has additional regular lists' do
        let!(:third_list) { create(:shopping_list_with_list_items, game:) }

        let(:expected_resource) do
          {
            deleted: [shopping_list.id],
            aggregate: game.aggregate_shopping_list,
          }
        end

        before do
          shopping_list.list_items.each do |list_item|
            game.aggregate_shopping_list.add_item_from_child_list(list_item)
          end

          third_list.list_items.each do |list_item|
            game.aggregate_shopping_list.add_item_from_child_list(list_item)
          end
        end

        it 'destroys the shopping list' do
          expect { perform }
            .to change(game.shopping_lists, :count).from(3).to(2)
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

        it 'includes the deleted list ID and the aggregate list as the resource' do
          expect(perform.resource).to eq expected_resource
        end

        describe 'updating the aggregate list' do
          before do
            items = create_list(:shopping_list_item, 2, list: third_list)
            items.each {|item| shopping_list.aggregate_list.add_item_from_child_list(item) }

            # Because in the code it finds the shopping list by ID and then gets the aggregate list
            # off that instance, the tests don't have access to the instance of the aggregate list that
            # the method is actually being called on, so we have to resort to this hack.
            user_lists = user.shopping_lists
            allow(user).to receive(:shopping_lists).and_return(user_lists)
            allow(user_lists).to receive(:find).and_return(shopping_list)
            allow(shopping_list).to receive(:aggregate_list).and_return(shopping_list.aggregate_list)
            allow(shopping_list.aggregate_list).to receive(:remove_item_from_child_list).twice
          end

          it 'calls #remove_item_from_child_list for each item', :aggregate_failures do
            perform

            shopping_list.list_items.each do |item|
              expect(aggregate_list).to have_received(:remove_item_from_child_list).with(item.attributes)
            end
          end
        end
      end

      context "when this is the game's last regular list" do
        let(:expected_resource) do
          {
            deleted: [shopping_list.aggregate_list_id, shopping_list.id],
          }
        end

        before do
          shopping_list.list_items.each do |item|
            game.aggregate_shopping_list.add_item_from_child_list(item)
          end
        end

        it 'destroys the aggregate list too' do
          expect { perform }
            .to change(game.shopping_lists, :count).from(2).to(0)
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

        it 'returns an array of deleted list IDs as the resource' do
          expect(perform.resource).to eq expected_resource
        end
      end
    end

    context 'when the list is an aggregate list' do
      let!(:shopping_list) { create(:aggregate_shopping_list, game:) }
      let(:game) { create(:game, user:) }

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a(Service::MethodNotAllowedResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq ['Cannot manually delete an aggregate shopping list']
      end
    end

    context 'when the list does not exist' do
      let(:shopping_list) { double('list that does not exist', id: 838) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any data", :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end

    context 'when the list belongs to another user' do
      let!(:shopping_list) { create(:shopping_list) }

      it "doesn't destroy the shopping list" do
        expect { perform }
          .not_to change(ShoppingList, :count)
      end

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't return any data", :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end

    context 'when something unexpected goes wrong' do
      let!(:shopping_list) { create(:shopping_list, game:) }
      let(:game) { create(:game, user:) }

      before do
        allow_any_instance_of(ShoppingList).to receive(:aggregate_list).and_raise(StandardError.new('Something went horribly wrong'))
      end

      it 'returns a Service::InternalServerErrorResult' do
        expect(perform).to be_a(Service::InternalServerErrorResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq ['Something went horribly wrong']
      end
    end
  end
end
