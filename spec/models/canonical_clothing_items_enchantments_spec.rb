# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalClothingItemsEnchantment, type: :model do
  describe 'validations' do
    it 'is valid with valid associations' do
      clothing_item = create(:canonical_clothing_item)
      enchantment   = create(:enchantment)
      model         = described_class.new(canonical_clothing_item: clothing_item, enchantment: enchantment)

      expect(model).to be_valid
    end

    describe 'canonical clothing item' do
      it 'is invalid without a canonical clothing item' do
        enchantment = create(:enchantment)
        item        = described_class.new(enchantment: enchantment)

        item.validate
        expect(item.errors[:canonical_clothing_item_id]).to include "can't be blank"
      end
    end

    describe 'enchantment' do
      it 'is invalid without an enchantment' do
        clothing_item = create(:canonical_clothing_item)
        item          = described_class.new(canonical_clothing_item: clothing_item)

        item.validate
        expect(item.errors[:enchantment_id]).to include "can't be blank"
      end
    end

    describe 'strength' do
      it 'is invalid with a non-numeric strength value' do
        clothing_item = create(:canonical_clothing_item)
        enchantment   = create(:enchantment)
        model         = described_class.new(canonical_clothing_item: clothing_item, enchantment: enchantment, strength: 'foo')

        model.validate
        expect(model.errors[:strength]).to include 'is not a number'
      end

      it 'is invalid with a negative strength value' do
        clothing_item = create(:canonical_clothing_item)
        enchantment   = create(:enchantment)
        model         = described_class.new(canonical_clothing_item: clothing_item, enchantment: enchantment, strength: -4)

        model.validate
        expect(model.errors[:strength]).to include 'must be greater than 0'
      end
    end
  end
end
