# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'

RSpec.describe ShoppingListsController::IndexService do
  describe '#perform' do
    subject(:perform) { described_class.new(user).perform }

    let(:user) { create(:user) }

    context 'when the user has no shopping lists' do
      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it 'sets the resource to be an empty array' do
        expect(perform.resource).to eq []
      end
    end

    context 'when the user has shopping lists' do
      let!(:master_list) { create(:master_shopping_list, user: user) }
      let!(:lists) { create_list(:shopping_list_with_list_items, 2, user: user) }

      it 'returns a Service::OKResult' do
        expect(perform).to be_a(Service::OKResult)
      end

      it "sets the resource to the user's shopping lists" do
        expect(perform.resource).to eq user.shopping_lists.index_order
      end
    end
  end
end