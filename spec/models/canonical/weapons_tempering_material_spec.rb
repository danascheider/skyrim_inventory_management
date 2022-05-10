# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::WeaponsTemperingMaterial, type: :model do
  describe 'validations' do
    describe 'quantity' do
      it "can't be blank" do
        model = build(:canonical_weapons_tempering_material, quantity: nil)

        model.validate
        expect(model.errors[:quantity]).to include "can't be blank"
      end

      it 'must be a number' do
        model = build(:canonical_weapons_tempering_material, quantity: 'foobar')

        model.validate
        expect(model.errors[:quantity]).to include 'is not a number'
      end

      it 'must be an integer' do
        model = build(:canonical_weapons_tempering_material, quantity: 3.14159)

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end

      it 'must be greater than zero' do
        model = build(:canonical_weapons_tempering_material, quantity: -2)

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end
    end

    describe 'canonical weapon and canonical material' do
      let(:weapon)   { create(:canonical_weapon) }
      let(:material) { create(:canonical_material) }

      it 'forms a unique combination' do
        create(:canonical_weapons_tempering_material, weapon: weapon, material: material)
        model = build(:canonical_weapons_tempering_material, weapon: weapon, material: material)

        model.validate
        expect(model.errors[:weapon_id]).to include 'must form a unique combination with canonical material'
      end
    end
  end
end
