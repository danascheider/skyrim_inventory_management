# frozen_string_literal: true

require 'rails_helper'

RSpec.describe :user, type: :model do
  subject(:user) { create(:user) }

  describe '#master_shopping_list' do
    context 'when the user has a master shopping list' do
      let!(:master_list) { create(:master_shopping_list, user: user) }

      it 'returns the master list' do
        expect(user.master_shopping_list).to eq master_list
      end
    end

    context 'when the user has no master shopping list' do
      it 'returns nil' do
        expect(user.master_shopping_list).to be nil
      end
    end
  end
end
