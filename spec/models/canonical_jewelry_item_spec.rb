# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalJewelryItem, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid with no name' do
        item = described_class.new(item_code: 'xxx', jewelry_type: 'amulet', unit_weight: 1.0)

        item.validate
        expect(item.errors[:name]).to include "can't be blank"
      end

      it 'is valid with a name' do
        item = build(:canonical_jewelry_item, name: 'foo')

        expect(item).to be_valid
      end
    end

    describe 'item_code' do
      it 'is invalid without an item code' do
        item = described_class.new(name: 'foo', jewelry_type: 'amulet', unit_weight: 4.2)

        item.validate
        expect(item.errors[:item_code]).to include "can't be blank"
      end

      it 'is invalid with a non-unique item code' do
        create(:canonical_jewelry_item, item_code: 'xxx')
        item = build(:canonical_jewelry_item, item_code: 'xxx')

        item.validate
        expect(item.errors[:item_code]).to include 'must be unique'
      end

      it 'is valid with a unique item code' do
        item = build(:canonical_jewelry_item, item_code: 'xxx')

        expect(item).to be_valid
      end
    end

    describe 'jewelry_type' do
      it 'is invalid without a jewelry_type' do
        item = described_class.new(name: 'foo', item_code: 'xxx', unit_weight: 1.0)

        item.validate
        expect(item.errors[:jewelry_type]).to include "can't be blank"
      end

      it 'is invalid with an invalid jewelry_type' do
        item = build(:canonical_jewelry_item, jewelry_type: 'bar')

        item.validate
        expect(item.errors[:jewelry_type]).to include 'must be "ring", "circlet", or "amulet"'
      end

      it 'is valid with a valid jewelry_type' do
        item = build(:canonical_jewelry_item, jewelry_type: 'circlet')

        expect(item).to be_valid
      end
    end

    describe 'unit_weight' do
      it 'is invalid without a unit weight' do
        item = described_class.new(name: 'foo', jewelry_type: 'ring')

        item.validate
        expect(item.errors[:unit_weight]).to include "can't be blank"
      end

      it 'is invalid with a non-numeric unit weight' do
        item = build(:canonical_jewelry_item, unit_weight: 'bar')

        item.validate
        expect(item.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid with a negative unit weight' do
        item = build(:canonical_jewelry_item, unit_weight: -4.3)

        item.validate
        expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end
  end
end
