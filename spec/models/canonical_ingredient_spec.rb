# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalIngredient, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      ingredient = described_class.new(name: 'Skeever Tail', item_code: 'foo', unit_weight: 1)
      expect(ingredient).to be_valid
    end

    describe 'name' do
      it 'must be present' do
        ingredient = described_class.new(item_code: 'foo')

        ingredient.validate
        expect(ingredient.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it 'must be present' do
        ingredient = described_class.new(name: 'Glowing Mushroom')

        ingredient.validate
        expect(ingredient.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_ingredient, item_code: 'foo')
        ingredient = build(:canonical_ingredient, name: 'Thistle Branch', item_code: 'foo')

        ingredient.validate
        expect(ingredient.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit_weight' do
      it 'must be present' do
        ingredient = described_class.new(name: 'Thistle Branch', item_code: 'foo')

        ingredient.validate
        expect(ingredient.errors[:unit_weight]).to include "can't be blank"
      end

      it "can't be less than zero" do
        ingredient = build(:canonical_ingredient, unit_weight: -0.5)

        ingredient.validate
        expect(ingredient.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end
  end
end
