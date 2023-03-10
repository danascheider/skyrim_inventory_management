# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::ClothingItem, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      model = described_class.new(
        name:        'Clothes',
        item_code:   'foo',
        unit_weight: 1,
        body_slot:   'body',
        purchasable: true,
        unique_item: false,
        rare_item:   false,
      )

      expect(model).to be_valid
    end

    describe 'name' do
      it "can't be blank" do
        model = build(:canonical_clothing_item, name: nil)

        model.validate
        expect(model.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it "can't be blank" do
        model = build(:canonical_clothing_item, item_code: nil)

        model.validate
        expect(model.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_clothing_item, item_code: 'xxx')
        model = build(:canonical_clothing_item, item_code: 'xxx')

        model.validate
        expect(model.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit_weight' do
      it "can't be blank" do
        model = build(:canonical_clothing_item, unit_weight: nil)

        model.validate
        expect(model.errors[:unit_weight]).to include "can't be blank"
      end

      it 'must be a number' do
        model = build(:canonical_clothing_item, unit_weight: 'bar')

        model.validate
        expect(model.errors[:unit_weight]).to include 'is not a number'
      end

      it 'must be at least zero' do
        model = build(:canonical_clothing_item, unit_weight: -34)

        model.validate
        expect(model.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe 'body_slot' do
      it "can't be blank" do
        model = build(:canonical_clothing_item, body_slot: nil)

        model.validate
        expect(model.errors[:body_slot]).to include "can't be blank"
      end

      it 'must have one of the valid values' do
        model = build(:canonical_clothing_item, body_slot: 'bar')

        model.validate
        expect(model.errors[:body_slot]).to include 'must be "head", "hands", "body", or "feet"'
      end
    end

    describe 'purchasable' do
      it 'must be true or false' do
        model = build(:canonical_clothing_item, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end
    end

    describe 'unique_item' do
      it 'must be true or false' do
        model = build(:canonical_clothing_item, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it 'must be true or false' do
        model = build(:canonical_clothing_item, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if item is unique' do
        model = build(:canonical_clothing_item, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'quest_item' do
      it 'must be true or false' do
        model = build(:canonical_clothing_item, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end

    describe 'enchantable' do
      it 'must be true or false' do
        model = build(:canonical_clothing_item, enchantable: nil)

        model.validate
        expect(model.errors[:enchantable]).to include 'must be true or false'
      end
    end
  end

  describe 'default behavior' do
    it 'upcases item codes' do
      item = create(:canonical_clothing_item, item_code: 'abc123')
      expect(item.reload.item_code).to eq 'ABC123'
    end
  end

  describe 'associations' do
    describe 'enchantments' do
      let(:item) { create(:canonical_clothing_item) }
      let(:enchantment) { create(:enchantment) }

      before do
        item.canonical_enchantables_enchantments.create!(enchantment:, strength: 14)
      end

      it 'gives the enchantment strength' do
        expect(item.enchantments.first.strength).to eq 14
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
