# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::ArmorsTemperingMaterial, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      material = create(:canonical_material)
      armor    = create(:canonical_armor)
      model    = described_class.new(quantity: 3, material: material, armor: armor)

      expect(model).to be_valid
    end

    describe 'quantity' do
      it 'is invalid if quantity is 0 or less' do
        model = build(:canonical_armors_tempering_material, quantity: 0)

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end

      it 'is invalid if quantity is not an integer' do
        model = build(:canonical_armors_tempering_material, quantity: 7.6)

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end
    end

    describe 'canonical armor and canonical material' do
      let(:material) { create(:canonical_material) }
      let(:armor)    { create(:canonical_armor) }

      it 'must be a unique combination' do
        create(:canonical_armors_tempering_material, material: material, armor: armor)
        model = build(:canonical_armors_tempering_material, material: material, armor: armor)

        model.validate
        expect(model.errors[:material_id]).to include 'must form a unique combination with canonical armor item'
      end
    end
  end
end