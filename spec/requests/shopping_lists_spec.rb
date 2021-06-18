# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "ShoppingLists", type: :request do
  describe 'POST /shopping_lists' do
    describe 'when authenticated' do
      #
    end

    describe 'when unauthenticated' do
      it 'returns 401' do
        post '/shopping_lists', params: {}
        expect(response.status).to eq 401
      end
    end
  end
end
