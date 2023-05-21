# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Armor, type: :model do
  describe 'validations' do
    describe 'name' do
      it "can't be blank" do
        armor = described_class.new(weight: 'heavy armor', item_code: 'xxx', unit_weight: 1.0, body_slot: 'body')

        armor.validate
        expect(armor.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it "can't be blank" do
        armor = described_class.new(name: 'foo', weight: 'heavy armor', unit_weight: 1.0, body_slot: 'body')

        armor.validate
        expect(armor.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_armor, item_code: 'xxx')
        armor = build(:canonical_armor, item_code: 'xxx')

        armor.validate
        expect(armor.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'weight' do
      it "can't be blank" do
        armor = described_class.new(name: 'fur armor', item_code: 'xxx', unit_weight: 2.5, body_slot: 'head')

        armor.validate
        expect(armor.errors[:weight]).to include "can't be blank"
      end

      it 'is invalid with an invalid weight value' do
        armor = build(:canonical_armor, weight: 'medium armor')

        armor.validate
        expect(armor.errors[:weight]).to include 'must be "light armor" or "heavy armor"'
      end
    end

    describe 'body_slot' do
      it 'is invalid without a body slot' do
        armor = described_class.new(name: 'fur armor', weight: 'light armor', unit_weight: 47.0)

        armor.validate
        expect(armor.errors[:body_slot]).to include "can't be blank"
      end

      it 'is invalid without a valid body slot value' do
        armor = build(:canonical_armor, body_slot: 'foo')

        armor.validate
        expect(armor.errors[:body_slot]).to include 'must be "head", "body", "hands", "feet", "hair", or "shield"'
      end

      it 'is valid with a valid body slot' do
        armor = build(:canonical_armor, body_slot: 'hair')

        expect(armor).to be_valid
      end
    end

    describe 'unit_weight' do
      it 'is invalid without a unit weight' do
        armor = described_class.new(name: 'steel helmet', weight: 'heavy armor', body_slot: 'head')

        armor.validate
        expect(armor.errors[:unit_weight]).to include "can't be blank"
      end

      it 'is invalid with a non-numeric unit weight' do
        armor = build(:canonical_armor, unit_weight: 'foo')

        armor.validate
        expect(armor.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid with a negative unit weight' do
        armor = build(:canonical_armor, unit_weight: -2.4)

        armor.validate
        expect(armor.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end

      it 'is valid with a valid unit weight' do
        armor = build(:canonical_armor, unit_weight: 2.4)

        expect(armor).to be_valid
      end
    end

    describe 'smithing_perks' do
      it 'must include only valid smithing perks' do
        model = build(:canonical_armor, smithing_perks: ['Titanium Smithing'])

        model.validate
        expect(model.errors[:smithing_perks]).to include '"Titanium Smithing" is not a valid smithing perk'
      end
    end

    describe 'leveled' do
      it 'must be true or false' do
        model = build(:canonical_armor, leveled: nil)

        model.validate
        expect(model.errors[:leveled]).to include 'must be true or false'
      end
    end

    describe 'purchasable' do
      it 'must be true or false' do
        model = build(:canonical_armor, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end
    end

    describe 'unique_item' do
      it 'must be true or false' do
        model = build(:canonical_armor, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it 'must be true or false' do
        model = build(:canonical_armor, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if the item is unique' do
        model = build(:canonical_armor, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'quest_item' do
      it 'must be true or false' do
        model = build(:canonical_armor, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end

    describe 'enchantable' do
      it 'must be true or false' do
        model = build(:canonical_armor, enchantable: nil)

        model.validate
        expect(model.errors[:enchantable]).to include 'must be true or false'
      end
    end
  end

  describe 'default behavior' do
    it 'upcases item codes' do
      armor = create(:canonical_armor, item_code: 'abc123')
      expect(armor.reload.item_code).to eq 'ABC123'
    end
  end

  describe 'associations' do
    describe 'enchantments' do
      let(:armor) { create(:canonical_armor) }
      let(:enchantment) { create(:enchantment) }

      before do
        armor.canonical_enchantables_enchantments.create!(enchantment:, strength: 40)
      end

      it 'gives the enchantment strength' do
        expect(armor.enchantments.first.strength).to eq 40
      end
    end

    describe 'smithing materials' do
      let(:armor) { create(:canonical_armor) }
      let(:material) { create(:canonical_material) }

      before do
        armor.canonical_craftables_crafting_materials.create!(material:, quantity: 4)
      end

      it 'gives the quantity needed' do
        expect(armor.crafting_materials.first.quantity_needed).to eq 4
      end
    end

    describe 'tempering materials' do
      let(:armor) { create(:canonical_armor) }
      let(:material) { create(:canonical_material) }

      before do
        armor.canonical_temperables_tempering_materials.create!(material:, quantity: 1)
      end

      it 'gives the quantity needed' do
        expect(armor.tempering_materials.first.quantity_needed).to eq 1
      end
    end
  end

  describe 'class methods' do
    describe 'unique_identifier' do
      it 'returns :item_code' do
        expect(described_class.unique_identifier).to eq :item_code
      end
    end
  end

  describe 'instance_methods' do
    describe '#matches?' do
      subject(:matches) { canonical_armor.matches?(armor) }

      let(:canonical_armor) { create(:canonical_armor) }

      context 'when the passed-in item matches but has blank fields' do
        let(:armor) do
          build(
            :armor,
            name: canonical_armor.name,
            unit_weight: nil,
            weight: nil,
            magical_effects: nil,
          )
        end

        it 'matches' do
          expect(matches).to be true
        end
      end

      context "when the passed-in item doesn't match" do
        let(:armor) do
          build(
            :armor,
            name: canonical_armor.name,
            weight: canonical_armor.weight,
            unit_weight: 27.2,
          )
        end

        it "doesn't match" do
          expect(matches).to be false
        end
      end
    end
  end
end
