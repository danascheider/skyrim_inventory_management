# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalWeaponsEnchantment, type: :model do
  describe 'validations' do
    describe 'canonical weapon and enchantment' do
      let(:enchantment) { create(:enchantment) }
      let(:weapon)      { create(:canonical_weapon) }

      it 'must form a unique combination' do
        create(:canonical_weapons_enchantment, canonical_weapon: weapon, enchantment: enchantment)
        model = build(:canonical_weapons_enchantment, canonical_weapon: weapon, enchantment: enchantment)

        model.validate
        expect(model.errors[:enchantment_id]).to include 'must form a unique combination with canonical weapon'
      end
    end

    describe 'strength' do
      it 'can be blank' do
        model = build(:canonical_weapons_enchantment, strength: nil)

        expect(model).to be_valid
      end

      it 'must be greater than zero' do
        model = build(:canonical_weapons_enchantment, strength: 0)

        model.validate
        expect(model.errors[:strength]).to include 'must be greater than 0'
      end
    end
  end
end
