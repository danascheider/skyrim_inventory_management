# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalWeaponsSmithingMaterial, type: :model do
  describe 'validations' do
    describe 'quantity' do
      it "can't be blank" do
        model = build(:canonical_weapons_smithing_material, quantity: nil)

        model.validate
        expect(model.errors[:quantity]).to include "can't be blank"
      end

      it 'must be a number' do
        model = build(:canonical_weapons_smithing_material, quantity: 'foobar')

        model.validate
        expect(model.errors[:quantity]).to include 'is not a number'
      end

      it 'must be greater than zero' do
        model = build(:canonical_weapons_smithing_material, quantity: -4)

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end

      it 'must be an integer' do
        model = build(:canonical_weapons_smithing_material, quantity: 3.3)

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end
    end

    describe 'canonical weapon and canonical material' do
      let(:weapon)   { create(:canonical_weapon) }
      let(:material) { create(:canonical_material) }

      it 'must form a unique combination' do
        create(:canonical_weapons_smithing_material, canonical_weapon: weapon, canonical_material: material)
        model = build(:canonical_weapons_smithing_material, canonical_weapon: weapon, canonical_material: material)

        model.validate
        expect(model.errors[:canonical_weapon_id]).to include 'must form a unique combination with canonical material'
      end
    end
  end
end
