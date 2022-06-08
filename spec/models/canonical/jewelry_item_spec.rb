# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::JewelryItem, type: :model do
  describe 'validations' do
    describe 'name' do
      it "can't be blank" do
        model = build(:canonical_jewelry_item, name: nil)

        model.validate
        expect(model.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it "can't be blank" do
        model = build(:canonical_jewelry_item, item_code: nil)

        model.validate
        expect(model.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_jewelry_item, item_code: 'xxx')
        model = build(:canonical_jewelry_item, item_code: 'xxx')

        model.validate
        expect(model.errors[:item_code]).to include 'must be unique'
      end

      it 'is valid with a unique item code' do
        item = build(:canonical_jewelry_item, item_code: 'xxx')

        expect(item).to be_valid
      end
    end

    describe 'jewelry_type' do
      it 'is invalid without a jewelry_type' do
        model = build(:canonical_jewelry_item, jewelry_type: nil)

        model.validate
        expect(model.errors[:jewelry_type]).to include "can't be blank"
      end

      it 'is invalid with an invalid jewelry_type' do
        model = build(:canonical_jewelry_item, jewelry_type: 'bar')

        model.validate
        expect(model.errors[:jewelry_type]).to include 'must be "ring", "circlet", or "amulet"'
      end
    end

    describe 'unit_weight' do
      it 'is invalid without a unit weight' do
        model = build(:canonical_jewelry_item, unit_weight: nil)

        model.validate
        expect(model.errors[:unit_weight]).to include "can't be blank"
      end

      it 'is invalid with a non-numeric unit weight' do
        model = build(:canonical_jewelry_item, unit_weight: 'bar')

        model.validate
        expect(model.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid with a negative unit weight' do
        model = build(:canonical_jewelry_item, unit_weight: -4.3)

        model.validate
        expect(model.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe 'purchasable' do
      it 'must be true or false' do
        model = build(:canonical_jewelry_item, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end
    end

    describe 'unique_item' do
      it 'must be true or false' do
        model = build(:canonical_jewelry_item, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it 'must be true or false' do
        model = build(:canonical_jewelry_item, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if the item is unique' do
        model = build(:canonical_jewelry_item, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'quest_item' do
      it 'must be true or false' do
        model = build(:canonical_jewelry_item, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end

    describe 'enchantable' do
      it 'must be true or false' do
        model = build(:canonical_jewelry_item, enchantable: nil)

        model.validate
        expect(model.errors[:enchantable]).to include 'must be true or false'
      end
    end
  end

  describe 'associations' do
    describe 'enchantments' do
      let(:item)        { create(:canonical_jewelry_item) }
      let(:enchantment) { create(:enchantment) }

      before do
        item.canonical_enchantables_enchantments.create!(enchantment:, strength: 17)
      end

      it 'gives the enchantment strength' do
        expect(item.enchantments.first.strength).to eq 17
      end
    end

    describe 'materials' do
      let(:item)     { create(:canonical_jewelry_item) }
      let(:material) { create(:canonical_material) }

      before do
        item.canonical_craftables_crafting_materials.create!(material:, quantity: 2)
      end

      it 'gives the quantity needed' do
        expect(item.crafting_materials.first.quantity_needed).to eq 2
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
