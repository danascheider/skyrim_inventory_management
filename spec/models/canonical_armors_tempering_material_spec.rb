# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalArmorsTemperingMaterial, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      material = create(:canonical_material)
      armor    = create(:canonical_armor)
      model    = described_class.new(quantity: 3, canonical_material: material, canonical_armor: armor)

      expect(model).to be_valid
    end

    describe 'quantity' do
      it 'is invalid if quantity is 0 or less' do
        material = create(:canonical_material)
        armor    = create(:canonical_armor)
        model    = described_class.new(quantity: 0, canonical_material: material, canonical_armor: armor)

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end

      it 'is invalid if quantity is not an integer' do
        material = create(:canonical_material)
        armor    = create(:canonical_armor)
        model    = described_class.new(quantity: 7.6, canonical_material: material, canonical_armor: armor)

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end
    end

    describe 'canonical armor and canonical material' do
      let(:material) { create(:canonical_material) }
      let(:armor)    { create(:canonical_armor) }

      it 'must be a unique combination' do
        create(:canonical_armors_tempering_material, canonical_material: material, canonical_armor: armor)
        model = described_class.new(canonical_material: material, canonical_armor: armor, quantity: 1)

        model.validate
        expect(model.errors[:canonical_material_id]).to include 'must form a unique combination with canonical armor item'
      end
    end
  end
end
