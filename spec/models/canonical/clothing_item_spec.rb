# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::ClothingItem, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      item = described_class.new(name: 'Clothes', item_code: 'foo', unit_weight: 1, body_slot: 'body')

      expect(item).to be_valid
    end

    describe 'name' do
      it 'is invalid without a name' do
        item = described_class.new(item_code: 'xxx', body_slot: 'hands', unit_weight: 4.2)

        item.validate
        expect(item.errors[:name]).to include "can't be blank"
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
      it 'is invalid with no unit weight' do
        item = described_class.new(name: 'Fine Clothes', item_code: 'foo', body_slot: 'body')

        item.validate
        expect(item.errors[:unit_weight]).to include "can't be blank"
      end

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
    end
  end

  describe 'associations' do
    describe 'enchantments' do
      let(:item)        { create(:canonical_clothing_item) }
      let(:enchantment) { create(:enchantment) }

      before do
        item.canonical_enchantables_enchantments.create!(enchantment: enchantment, strength: 14)
      end

      it 'gives the enchantment strength' do
        expect(item.enchantments.first.strength).to eq 14
      end
    end
  end

  describe 'class methods' do
    describe '::unique_identifier' do
      subject(:unique_identifier) { described_class.unique_identifier }

      it 'returns :item_code' do
        expect(unique_identifier).to eq :item_code
      end
    end
  end
end
