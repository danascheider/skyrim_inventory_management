# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::EnchantablesEnchantment, type: :model do
  describe 'validations' do
    describe 'enchantable item and enchantment' do
      let(:enchantment) { create(:enchantment) }
      let(:armor)       { create(:canonical_armor) }

      it 'must form a unique combination' do
        create(:canonical_enchantables_enchantment, :for_armor, enchantable: armor, enchantment:)
        model = build(:canonical_enchantables_enchantment, :for_armor, enchantable: armor, enchantment:)

        model.validate
        expect(model.errors[:enchantment_id]).to include 'must form a unique combination with enchantable item'
      end
    end

    describe 'polymorphic associations' do
      subject(:enchantable_type) { described_class.new(enchantable: item, enchantment: create(:enchantment)).enchantable_type }

      context 'when the association is an armor item' do
        let(:item) { create(:canonical_armor) }

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Canonical::Armor'
        end
      end

      context 'when the association is a weapon' do
        let(:item) { create(:canonical_weapon) }

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Canonical::Weapon'
        end
      end

      context 'when the association is a jewelry item' do
        let(:item) { create(:canonical_jewelry_item) }

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Canonical::JewelryItem'
        end
      end

      context 'when the association is a clothing item' do
        let(:item) { create(:canonical_clothing_item) }

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Canonical::ClothingItem'
        end
      end
    end
  end
end
