# frozen_string_literal: true

require 'rails_helper'
require 'service/result'
require 'controller/response'

RSpec.describe Controller::Response do
  describe '#execute' do
    subject(:execute) { described_class.new(controller, result, options).execute }

    context 'when the response status is 401' do
      let(:controller) { instance_double(VerificationsController, head: nil) }
      let(:options) { {} }
      let(:result) do
        instance_double(Service::Result,
          unauthorized?: true,
          not_found?: false,
          method_not_allowed?: false,
          errors: []
        )
      end

      it 'returns a 401 response with no response body' do
        execute
        expect(controller).to have_received(:head).with(:unauthorized)
      end
    end

    context 'when the response status is 404' do
      let(:controller) { instance_double(ShoppingListsController, head: nil) }
      let(:options) { {} }
      let(:result) do
        instance_double(Service::Result,
          unauthorized?: false,
          not_found?: true,
          method_not_allowed?: false,
          errors: []
        )
      end

      it 'returns a 404 error with no response body' do
        execute
        expect(controller).to have_received(:head).with(:not_found)
      end
    end

    context 'when the response status is 405' do
      let(:controller) { instance_double(ShoppingListsController, render: nil) }
      let(:errors) { ['Cannot manually update a master shopping list'] }
      let(:options) { {} }
      let(:result) do
        instance_double(Service::Result,
          unauthorized?: false,
          not_found?: false,
          method_not_allowed?: true,
          errors: errors
        )
      end

      it 'returns a 405 error with the errors' do
        execute
        expect(controller).to have_received(:render).with(json: { errors: errors }, status: :method_not_allowed)
      end
    end

    context 'when the response status is 422' do
      let(:controller) { instance_double(ShoppingListsController, render: nil) }
      let(:options) { {} }
      let(:errors) { ['Title is already taken', 'Cannot manually create or update a master list'] }
      let(:result) do
        instance_double(Service::Result,
          unauthorized?: false,
          not_found?: false,
          method_not_allowed?: false,
          unprocessable_entity?: true,
          errors: errors
        )
      end

      it 'renders the errors' do
        execute
        expect(controller).to have_received(:render).with(json: { errors: errors }, status: :unprocessable_entity)
      end
    end

    context 'when the response status is 200' do
      let(:controller) { instance_double(ShoppingListsController, render: nil) }
      let(:options) { {} }

      let(:resource) do
        {
          id: 927,
          user_id: 72,
          title: 'My List 2',
          created_at: Time.now - 2.days,
          updated_at: Time.now
        }
      end

      let(:result) do
        instance_double(Service::Result,
          unauthorized?: false,
          not_found?: false,
          method_not_allowed?: false,
          unprocessable_entity?: false,
          ok?: true,
          resource: resource
        )
      end

      it 'renders the resource' do
        execute
        expect(controller).to have_received(:render).with(json: resource, status: :ok)
      end
    end

    context 'when the response status is 201' do
      let(:controller) { instance_double(ShoppingListItemsController, render: nil) }
      let(:options) { {} }

      let(:resource) do
        [
          {
            id: 927,
            shopping_list_id: 72,
            description: 'Ebony sword',
            quantity: 2,
            notes: nil,
            created_at: Time.now - 2.days,
            updated_at: Time.now
          },
          {
            id: 926,
            shopping_list_id: 75,
            description: 'Ebony sword',
            quantity: 1,
            notes: nil,
            created_at: Time.now,
            updated_at: Time.now
          }            
        ]
      end

      let(:result) do
        instance_double(Service::Result,
          unauthorized?: false,
          not_found?: false,
          method_not_allowed?: false,
          unprocessable_entity?: false,
          ok?: false,
          created?: true,
          resource: resource
        )
      end

      it 'renders the resource' do
        execute
        expect(controller).to have_received(:render).with(json: resource, status: :created)
      end
    end

    context 'when the response status is 204' do
      let(:controller) { instance_double(ShoppingListItemsController, head: nil) }
      let(:options) { {} }

      let(:result) do
        instance_double(Service::Result,
          unauthorized?: false,
          not_found?: false,
          method_not_allowed?: false,
          unprocessable_entity?: false,
          ok?: false,
          created?: false,
          no_content?: true
        )
      end

      it 'renders the resource' do
        execute
        expect(controller).to have_received(:head).with(:no_content)
      end
    end
  end
end
