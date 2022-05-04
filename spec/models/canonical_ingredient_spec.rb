# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalIngredient, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      ingredient = described_class.new(name: 'Skeever Tail', item_code: 'foo')
      expect(ingredient).to be_valid
    end

    describe 'name' do
      it 'is invalid without a name' do
        ingredient = described_class.new(item_code: 'foo')

        ingredient.validate
        expect(ingredient.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it 'is invalid without an item code' do
        ingredient = described_class.new(name: 'Glowing Mushroom')

        ingredient.validate
        expect(ingredient.errors[:item_code]).to include "can't be blank"
      end

      it 'is invalid with a non-unique item code' do
        create(:canonical_ingredient, item_code: 'foo')
        ingredient = described_class.new(name: 'Thistle Branch', item_code: 'foo')

        ingredient.validate
        expect(ingredient.errors[:item_code]).to include 'must be unique'
      end
    end
  end
end
