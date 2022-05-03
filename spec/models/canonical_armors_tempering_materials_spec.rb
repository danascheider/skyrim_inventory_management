# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalArmorsTemperingMaterial, type: :model do
  describe 'validations' do
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

      it 'is valid with a valid quantity' do
        material = create(:canonical_material)
        armor    = create(:canonical_armor)
        model    = described_class.new(quantity: 3, canonical_material: material, canonical_armor: armor)

        expect(model).to be_valid
      end
    end
  end
end
