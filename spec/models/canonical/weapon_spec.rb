# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Weapon, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      weapon = described_class.new(
        name:           'Ebony Battleaxe',
        item_code:      '123xxx',
        category:       'two-handed',
        weapon_type:    'battleaxe',
        smithing_perks: ['Ebony Smithing'],
        base_damage:    18,
        unit_weight:    22,
        purchasable:    true,
        unique_item:    false,
        rare_item:      false,
        quest_item:     false,
        leveled:        false,
        enchantable:    true,
      )

      expect(weapon).to be_valid
    end

    describe 'name' do
      it "can't be blank" do
        weapon = build(:canonical_weapon, name: nil)

        weapon.validate
        expect(weapon.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item code' do
      it "can't be blank" do
        weapon = build(:canonical_weapon, item_code: nil)

        weapon.validate
        expect(weapon.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_weapon, item_code: 'foo')
        weapon = build(:canonical_weapon, item_code: 'foo')

        weapon.validate
        expect(weapon.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'category' do
      it "can't be blank" do
        weapon = build(:canonical_weapon, category: nil)

        weapon.validate
        expect(weapon.errors[:category]).to include "can't be blank"
      end

      it 'must be an allowed value' do
        weapon = build(:canonical_weapon, category: 'foo')

        weapon.validate
        expect(weapon.errors[:category]).to include 'must be "one-handed", "two-handed", or "archery"'
      end
    end

    describe 'weapon type' do
      it "can't be blank" do
        weapon = build(:canonical_weapon, weapon_type: nil)

        weapon.validate
        expect(weapon.errors[:weapon_type]).to include "can't be blank"
      end

      it 'must be an allowed value' do
        weapon = build(:canonical_weapon, weapon_type: 'foo')

        weapon.validate
        expect(weapon.errors[:weapon_type]).to include 'must be a valid type of weapon that occurs in Skyrim'
      end

      it 'must be valid for the category' do
        weapon = build(:canonical_weapon, category: 'one-handed', weapon_type: 'crossbow')

        weapon.validate
        expect(weapon.errors[:weapon_type]).to include 'is not included in category "one-handed"'
      end
    end

    describe 'smithing perks' do
      it 'must consist of only valid smithing perks', :aggregate_failures do
        weapon = build(:canonical_weapon, smithing_perks: ['Arcane Blacksmith', 'Silver Smithing', 'Titanium Smithing'])

        weapon.validate
        expect(weapon.errors[:smithing_perks]).to include '"Silver Smithing" is not a valid smithing perk'
        expect(weapon.errors[:smithing_perks]).to include '"Titanium Smithing" is not a valid smithing perk'
      end
    end

    describe 'base damage' do
      it 'must be present' do
        weapon = build(:canonical_weapon, base_damage: nil)

        weapon.validate
        expect(weapon.errors[:base_damage]).to include "can't be blank"
      end

      it 'must be a number' do
        weapon = build(:canonical_weapon, base_damage: 'foobar')

        weapon.validate
        expect(weapon.errors[:base_damage]).to include 'is not a number'
      end

      it 'must be an integer' do
        weapon = build(:canonical_weapon, base_damage: 1.2)

        weapon.validate
        expect(weapon.errors[:base_damage]).to include 'must be an integer'
      end

      it 'must be at least zero' do
        weapon = build(:canonical_weapon, base_damage: -2)

        weapon.validate
        expect(weapon.errors[:base_damage]).to include 'must be greater than or equal to 0'
      end
    end

    describe 'unit_weight' do
      it 'must be present' do
        weapon = build(:canonical_weapon, unit_weight: nil)

        weapon.validate
        expect(weapon.errors[:unit_weight]).to include "can't be blank"
      end

      it 'must be a number' do
        weapon = build(:canonical_weapon, unit_weight: 'foobar')

        weapon.validate
        expect(weapon.errors[:unit_weight]).to include 'is not a number'
      end

      it 'must be at least zero' do
        weapon = build(:canonical_weapon, unit_weight: -2)

        weapon.validate
        expect(weapon.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe 'purchasable' do
      it "can't be blank" do
        model = build(:canonical_weapon, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end
    end

    describe 'unique_item' do
      it 'must be true or false' do
        model = build(:canonical_weapon, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it 'must be true or false' do
        model = build(:canonical_weapon, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if the item is unique' do
        model = build(:canonical_weapon, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'quest_item' do
      it 'must be true or false' do
        model = build(:canonical_weapon, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end

    describe 'leveled' do
      it 'must be true or false' do
        model = build(:canonical_weapon, leveled: nil)

        model.validate
        expect(model.errors[:leveled]).to include 'must be true or false'
      end
    end

    describe 'enchantable' do
      it 'must be true or false' do
        model = build(:canonical_weapon, enchantable: nil)

        model.validate
        expect(model.errors[:enchantable]).to include 'must be true or false'
      end
    end
  end

  describe 'default behavior' do
    it 'upcases item codes' do
      weapon = create(:canonical_weapon, item_code: 'abc123')
      expect(weapon.reload.item_code).to eq 'ABC123'
    end
  end

  describe 'associations' do
    describe 'enchantments' do
      let(:weapon) { create(:canonical_weapon) }
      let(:enchantment) { create(:enchantment) }

      before do
        weapon.canonical_enchantables_enchantments.create!(enchantment:, strength: 40)
      end

      it 'gives the enchantment strength' do
        expect(weapon.enchantments.first.strength).to eq 40
      end
    end

    describe 'powers' do
      let(:weapon) { create(:canonical_weapon) }
      let(:power) { create(:power) }

      before do
        weapon.canonical_powerables_powers.create!(power:)
      end

      it 'retrieves the power' do
        expect(weapon.powers.first).to eq power
      end
    end

    describe 'crafting materials' do
      let(:weapon) { create(:canonical_weapon) }
      let(:material) { create(:canonical_material) }

      before do
        weapon.canonical_craftables_crafting_materials.create!(material:, quantity: 4)
      end

      it 'gives the quantity needed' do
        expect(weapon.crafting_materials.first.quantity_needed).to eq 4
      end
    end

    describe 'tempering materials' do
      let(:weapon) { create(:canonical_weapon) }
      let(:material) { create(:canonical_material) }

      before do
        weapon.canonical_temperables_tempering_materials.create!(material:, quantity: 4)
      end

      it 'gives the quantity needed' do
        expect(weapon.tempering_materials.first.quantity_needed).to eq 4
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
