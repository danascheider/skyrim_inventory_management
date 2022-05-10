# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::ClothingItemsEnchantment, type: :model do
  describe 'validations' do
    it 'is valid with valid associations' do
      clothing_item = create(:canonical_clothing_item)
      enchantment   = create(:enchantment)
      model         = described_class.new(canonical_clothing_item: clothing_item, enchantment: enchantment)

      expect(model).to be_valid
    end

    describe 'enchantment and canonical clothing item' do
      let(:clothing_item) { create(:canonical_clothing_item) }
      let(:enchantment)   { create(:enchantment) }

      it 'must form a unique combination' do
        create(:canonical_clothing_items_enchantment, canonical_clothing_item: clothing_item, enchantment: enchantment)
        item = build(:canonical_clothing_items_enchantment, canonical_clothing_item: clothing_item, enchantment: enchantment)

        item.validate
        expect(item.errors[:canonical_clothing_item_id]).to include 'must form a unique combination with enchantment'
      end
    end

    describe 'strength' do
      it 'is invalid with a non-numeric strength value' do
        model = build(:canonical_clothing_items_enchantment, strength: 'foo')

        model.validate
        expect(model.errors[:strength]).to include 'is not a number'
      end

      it 'is invalid with a negative strength value' do
        model = build(:canonical_clothing_items_enchantment, strength: -4)

        model.validate
        expect(model.errors[:strength]).to include 'must be greater than 0'
      end
    end
  end
end
