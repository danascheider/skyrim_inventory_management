# frozen_string_literal: true

require 'rails_helper'
require 'service/no_content_result'
require 'service/method_not_allowed_result'
require 'service/not_found_result'
require 'service/ok_result'

RSpec.describe ShoppingListsController::DestroyService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, shopping_list.id).perform }

    let(:user) { create(:user) }

    context 'when all goes well' do
      let!(:shopping_list) { create(:shopping_list_with_list_items, user: user) }

      context 'when the user has additional regular lists' do
        let!(:master_list) { user.master_shopping_list }
        let!(:third_list) { create(:shopping_list, user: user, master_list: master_list) }

        before do
          shopping_list.list_items.each do |list_item|
            master_list.add_item_from_child_list(list_item)
          end
        end

        it 'destroys the shopping list' do
          expect { perform }.to change(user.shopping_lists, :count).from(3).to(2)
        end

        it 'returns a Service::OKResult' do
          expect(perform).to be_a(Service::OKResult)
        end

        it 'sets the resource as the master list' do
          expect(perform.resource).to eq master_list
        end

        describe 'updating the master list' do
          before do
            items = create_list(:shopping_list_item, 2, list: third_list)
            items.each { |item| master_list.add_item_from_child_list(item) }

            # Because in the code it finds the shopping list by ID and then gets the master list
            # off that instance, the tests don't have access to the instance of the master list that
            # the method is actually being called on, so we have to resort to this hack.
            allow(user.shopping_lists).to receive(:find).and_return(shopping_list)
            allow(shopping_list).to receive(:master_list).and_return(master_list)
            allow(master_list).to receive(:remove_item_from_child_list).twice
          end

          it 'calls #remove_item_from_child_list for each item', :aggregate_failures do
            perform

            shopping_list.list_items.each do |item|
              puts master_list.inspect
              expect(master_list).to have_received(:remove_item_from_child_list).with(item.attributes)
            end
          end
        end
      end

      context "when this is the user's last regular list" do
        before do
          shopping_list.list_items.each do |item|
            shopping_list.master_list.add_item_from_child_list(item)
          end
        end

        it 'destroys the master list too' do
          expect { perform }.to change(user.shopping_lists, :count).from(2).to(0)
        end

        it 'returns a Service::NoContentResult' do
          expect(perform).to be_a(Service::NoContentResult)
        end
      end
    end

    context 'when the list is a master list' do
      let!(:shopping_list) { create(:master_shopping_list, user: user) }

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a(Service::MethodNotAllowedResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Cannot manually delete a master shopping list'])
      end
    end

    context 'when the list does not belong to the user' do
      let(:shopping_list) { create(:shopping_list) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end
    end

    context 'when the list does not exist' do
      let(:shopping_list) { double('list that does not exist', id: 838) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end
    end
  end
end
