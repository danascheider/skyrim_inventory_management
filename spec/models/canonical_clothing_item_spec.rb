# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalClothingItem, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid without a name' do
        item = described_class.new(item_code: 'xxx', body_slot: 'hands', unit_weight: 4.2)

        item.validate
        expect(item.errors[:name]).to include "can't be blank"
      end

      it 'is valid with name present' do
        item = build(:canonical_clothing_item, name: 'foo')

        expect(item).to be_valid
      end
    end

    describe 'item_code' do
      it 'is invalid without an item code' do
        item = described_class.new(name: 'Fine Clothes', unit_weight: 1, body_slot: 'body')

        item.validate
        expect(item.errors[:item_code]).to include "can't be blank"
      end

      it 'is invalid with a non-unique item code' do
        create(:canonical_clothing_item, item_code: 'xxx')
        item = build(:canonical_clothing_item, item_code: 'xxx')

        item.validate
        expect(item.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit_weight' do
      it 'is invalid with a non-numeric unit weight' do
        item = build(:canonical_clothing_item, unit_weight: 'bar')

        item.validate
        expect(item.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid with a negative unit weight' do
        item = build(:canonical_clothing_item, unit_weight: -34)

        item.validate
        expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end

      it 'is valid with a positive decimal unit weight value' do
        item = build(:canonical_clothing_item, unit_weight: 7.0)

        expect(item).to be_valid
      end
    end

    describe 'body_slot' do
      it 'is invalid without a body_slot' do
        item = described_class.new(name: 'foo', unit_weight: 2.0)

        item.validate
        expect(item.errors[:body_slot]).to include "can't be blank"
      end

      it 'is invalid with an invalid body_slot value' do
        item = build(:canonical_clothing_item, body_slot: 'bar')

        item.validate
        expect(item.errors[:body_slot]).to include 'must be "head", "hands", "body", or "feet"'
      end

      it 'is valid with a valid body_slot value' do
        item = build(:canonical_clothing_item, body_slot: 'feet')

        expect(item).to be_valid
      end
    end
  end
end
