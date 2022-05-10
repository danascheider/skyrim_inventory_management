# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::ArmorsSmithingMaterial, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      armor    = create(:canonical_armor)
      material = create(:canonical_material)
      model    = described_class.new(quantity: 2, armor: armor, material: material)

      expect(model).to be_valid
    end

    describe 'quantity' do
      it 'must be greater than zero' do
        armor    = create(:canonical_armor)
        material = create(:canonical_material)
        model    = described_class.new(quantity: 0, armor: armor, material: material)

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end

      it 'must be an integer' do
        armor    = create(:canonical_armor)
        material = create(:canonical_material)
        model    = described_class.new(quantity: 1.3, armor: armor, material: material)

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end
    end

    describe 'canonical material and canonical armor' do
      let(:material) { create(:canonical_material) }
      let(:armor)    { create(:canonical_armor) }

      it 'must form a unique combination' do
        create(:canonical_armors_smithing_material, material: material, armor: armor)
        model = build(:canonical_armors_smithing_material, quantity: 2, material: material, armor: armor)

        model.validate
        expect(model.errors[:armor_id]).to include 'must form a unique combination with canonical material'
      end
    end
  end
end
