# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'
require 'service/method_not_allowed_result'
require 'service/not_found_result'
require 'service/unprocessable_entity_result'

RSpec.describe ShoppingListsController::UpdateService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, shopping_list.id, params).perform }
    
    let!(:master_list) { create(:master_shopping_list, user: user) }
    let(:user) { create(:user) }
    
    context 'when all goes well' do
      let(:shopping_list) { create(:shopping_list, user: user) }
      let(:params) { { title: 'My New Title' } }

      it 'updates the shopping list' do
        perform
        expect(shopping_list.reload.title).to eq 'My New Title'
      end

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the resource to the updated shopping list' do
        expect(perform.resource).to eq shopping_list
      end
    end

    context 'when the params are invalid' do
      let(:shopping_list) { create(:shopping_list, user: user) }
      let(:params) { { title: '|nvalid Tit|e' } }

      it 'returns a Service::UnprocessableEntityResult' do
        expect(perform).to be_a(Service::UnprocessableEntityResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Title can only include alphanumeric characters and spaces'])
      end
    end

    context 'when the shopping list does not belong to the user' do
      let(:shopping_list) { create(:shopping_list) }
      let(:params) { { title: 'Valid New Title' } }
      
      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end
    end

    context 'when the shopping list is a master shopping list' do
      let(:shopping_list) { master_list }
      let(:params) { { title: 'New Title' } }

      it 'returns a Service::MethodNotAllowedResult' do
        expect(perform).to be_a(Service::MethodNotAllowedResult)
      end

      it 'sets the error message' do
        expect(perform.errors).to eq(['Cannot manually update a master shopping list'])
      end
    end

    context 'when the request tries to set master to true' do
      let(:shopping_list) { create(:shopping_list, user: user) }
      let(:params) { { master: true } }

      it 'returns a Service::UnprocessableEntityResult' do
        expect(perform).to be_a(Service::UnprocessableEntityResult)
      end

      it 'sets the error message' do
        expect(perform.errors).to eq(['Cannot make a regular shopping list a master list'])
      end
    end
  end
end
