# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalArmorsSmithingMaterial, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      armor    = create(:canonical_armor)
      material = create(:canonical_material)
      model    = described_class.new(quantity: 2, canonical_armor: armor, canonical_material: material)

      expect(model).to be_valid
    end

    describe 'quantity' do
      it 'is invalid if quantity is zero or less' do
        armor    = create(:canonical_armor)
        material = create(:canonical_material)
        model    = described_class.new(quantity: 0, canonical_armor: armor, canonical_material: material)

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end

      it 'is invalid if quantity is not an integer' do
        armor    = create(:canonical_armor)
        material = create(:canonical_material)
        model    = described_class.new(quantity: 1.3, canonical_armor: armor, canonical_material: material)

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end
    end

    describe 'canonical material and canonical armor' do
      let(:material) { create(:canonical_material) }
      let(:armor)    { create(:canonical_armor) }

      it 'must form a unique combination' do
        create(:canonical_armors_smithing_material, canonical_material: material, canonical_armor: armor)
        model = build(:canonical_armors_smithing_material, quantity: 2, canonical_material: material, canonical_armor: armor)

        model.validate
        expect(model.errors[:canonical_armor_id]).to include 'must form a unique combination with canonical material'
      end
    end
  end
end
