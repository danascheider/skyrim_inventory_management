# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Ingredient, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      ingredient = described_class.new(
                     name:                   'Skeever Tail',
                     item_code:              'foo',
                     ingredient_type:        'common',
                     unit_weight:            1,
                     purchasable:            true,
                     purchase_requires_perk: false,
                     unique_item:            false,
                     rare_item:              true,
                   )

      expect(ingredient).to be_valid
    end

    describe 'name' do
      it 'must be present' do
        model = build(:canonical_ingredient, name: nil)

        model.validate
        expect(model.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it 'must be present' do
        model = build(:canonical_ingredient, item_code: nil)

        model.validate
        expect(model.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_ingredient, item_code: 'foo')
        model = build(:canonical_ingredient, item_code: 'foo')

        model.validate
        expect(model.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'ingredient_type' do
      it 'must have one of the valid values' do
        model = build(:canonical_ingredient, ingredient_type: 'unique')

        model.validate
        expect(model.errors[:ingredient_type]).to include 'must be "common", "uncommon", "rare", or "Solstheim"'
      end

      it 'can be blank' do
        model = build(:canonical_ingredient, ingredient_type: nil)

        expect(model).to be_valid
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

    describe 'purchasable' do
      it 'must be true or false' do
        model = build(:canonical_ingredient, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end

      it 'must be true if ingredient_type is defined' do
        model = build(:canonical_ingredient, ingredient_type: 'rare', purchasable: false)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true if ingredient_type is set'
      end
    end

    describe 'purchase_requires_perk' do
      # Because non-nil values other than `true` or `false` will automatically
      # be converted to `true` prior to validation, it is pointless to test
      # that boolean values are validated when NULL is also allowed, since `nil`
      # is the only value that won't be converted.

      # This spec tests whether the model IS valid when purchase_requires_perk is nil and purchasable is false.
      # The next spec tests the validation error/message.
      it 'can be NULL if purchasable is false' do
        model = build(:canonical_ingredient, ingredient_type: nil, purchasable: false, purchase_requires_perk: nil)

        expect(model).to be_valid
      end

      # The above spec tests whether the model is valid when the value is nil and purchasable is false. This
      # spec tests the validation error/message.
      it 'must be NULL if purchasable is false' do
        model = build(:canonical_ingredient, ingredient_type: nil, purchasable: false, purchase_requires_perk: false)

        model.validate
        expect(model.errors[:purchase_requires_perk]).to include "can't be set if purchasable is false"
      end

      it 'must be set if purchasable is true' do
        model = build(:canonical_ingredient, ingredient_type: 'common', purchasable: true, purchase_requires_perk: nil)

        model.validate
        expect(model.errors[:purchase_requires_perk]).to include 'must be true or false if purchasable is true'
      end
    end

    describe 'unique_item' do
      it 'must be true or false' do
        model = build(:canonical_ingredient, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it 'must be true or false' do
        model = build(:canonical_ingredient, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if the ingredient is unique' do
        model = build(:canonical_ingredient, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'quest_item' do
      it 'must be true or false' do
        model = build(:canonical_ingredient, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end
  end

  describe 'class methods' do
    describe '::unique_identifier' do
      it 'returns :item_code' do
        expect(described_class.unique_identifier).to eq :item_code
      end
    end
  end
end
