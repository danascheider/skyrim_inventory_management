# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::JewelryItemsEnchantment, type: :model do
  describe 'validations' do
    describe 'strength' do
      it 'is invalid with a non-numeric strength value' do
        model = build(:canonical_jewelry_items_enchantment, strength: 'foo')

        model.validate
        expect(model.errors[:strength]).to include 'is not a number'
      end

      it 'is invalid with a negative strength value' do
        model = build(:canonical_jewelry_items_enchantment, strength: -4)

        model.validate
        expect(model.errors[:strength]).to include 'must be greater than 0'
      end
    end

    describe 'canonical jewelry item and enchantment' do
      let(:jewelry_item) { create(:canonical_jewelry_item) }
      let(:enchantment)  { create(:enchantment) }

      it 'must form a unique combination' do
        create(:canonical_jewelry_items_enchantment, canonical_jewelry_item: jewelry_item, enchantment: enchantment)
        model = build(
                  :canonical_jewelry_items_enchantment,
                  canonical_jewelry_item: jewelry_item,
                  enchantment:            enchantment,
                )

        model.validate
        expect(model.errors[:canonical_jewelry_item_id]).to include 'must form a unique combination with enchantment'
      end
    end
  end
end
