# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::CraftablesCraftingMaterial, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      armor = create(:canonical_armor)
      material = create(:canonical_material)
      model = described_class.new(quantity: 2, craftable: armor, material:)

      expect(model).to be_valid
    end

    describe 'quantity' do
      it 'must be greater than zero' do
        weapon = create(:canonical_weapon)
        material = create(:canonical_material)
        model = described_class.new(quantity: 0, craftable: weapon, material:)

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end

      it 'must be an integer' do
        item = create(:canonical_jewelry_item)
        material = create(:canonical_material)
        model = described_class.new(quantity: 1.3, craftable: item, material:)

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end
    end

    describe 'canonical material and craftable item' do
      let(:material) { create(:canonical_material) }
      let(:armor) { create(:canonical_armor) }

      it 'must form a unique combination' do
        create(:canonical_craftables_crafting_material, material:, craftable: armor)
        model = build(:canonical_craftables_crafting_material, quantity: 2, material:, craftable: armor)

        model.validate
        expect(model.errors[:material_id]).to include 'must form a unique combination with craftable item'
      end
    end
  end

  describe 'polymorphic associations' do
    subject(:craftable_type) { described_class.new(craftable: item, material: create(:canonical_material)).craftable_type }

    context 'when the association is an armor item' do
      let(:item) { create(:canonical_armor) }

      it 'sets the craftable type' do
        expect(craftable_type).to eq 'Canonical::Armor'
      end
    end

    context 'when the association is a weapon' do
      let(:item) { create(:canonical_weapon) }

      it 'sets the craftable type' do
        expect(craftable_type).to eq 'Canonical::Weapon'
      end
    end

    context 'when the association is a jewelry item' do
      let(:item) { create(:canonical_jewelry_item) }

      it 'sets the craftable type' do
        expect(craftable_type).to eq 'Canonical::JewelryItem'
      end
    end
  end
end
