# frozen_string_literal: true

require 'rails_helper'
require 'service/created_result'
require 'service/unprocessable_entity_result'

RSpec.describe ShoppingListsController::CreateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, params).perform }
    
    let(:user) { create(:user) }

    context 'when the request tries to create a master list' do
      let(:params) do
        {
          title: 'Master',
          master: true
        }
      end

      it 'returns a Service::UnprocessableEntityResult' do
        expect(perform).to be_a(Service::UnprocessableEntityResult)
      end

      it 'sets an error' do
        expect(perform.errors).to eq(['Cannot manually create a master shopping list'])
      end
    end

    context 'when params are valid' do
      let(:params) { { title: 'Proudspire Manor' } }

      context 'when the user has a master shopping list' do
        before do
          create(:master_shopping_list, user: user)
        end

        it 'creates a shopping list for the given user' do
          expect { perform }.to change(user.shopping_lists, :count).from(1).to(2)
        end

        it 'returns a Service::CreatedResult' do
          expect(perform).to be_a(Service::CreatedResult)
        end

        it 'sets the resource to the created list' do
          expect(perform.resource).to eq user.shopping_lists.last
        end
      end

      context "when the user doesn't have a master shopping list" do
        it 'creates two lists' do
          expect { perform }.to change(user.shopping_lists, :count).from(0).to(2)
        end

        it 'creates a master shopping list for the given user' do
          perform
          expect(user.master_shopping_list).to be_present
        end

        it 'creates a regular shopping list for the given user' do
          perform
          expect(user.shopping_lists.first.title).to eq 'Proudspire Manor'
        end

        it 'returns a Service::CreatedResult' do
          expect(perform).to be_a(Service::CreatedResult)
        end

        it 'sets the resource to include both lists' do
          expect(perform.resource).to eq([user.master_shopping_list, user.shopping_lists.first])
        end
      end
    end

    context 'when params are invalid' do
      let(:params) { { title: '|nvalid Tit|e' } }

      it 'does not create a shopping list' do
        expect { perform }.not_to change(user.shopping_lists, :count)
      end

      it 'returns a Service::UnprocessableEntityResult' do
        expect(perform).to be_a(Service::UnprocessableEntityResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Title can only include alphanumeric characters and spaces'])
      end
    end
  end
end
