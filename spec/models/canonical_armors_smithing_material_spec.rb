# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalArmorsSmithingMaterial, type: :model do
  describe 'validations' do
    describe 'count' do
      it 'is invalid if count is zero or less' do
        armor    = create(:canonical_armor)
        material = create(:canonical_material)
        model    = described_class.new(count: 0, canonical_armor: armor, canonical_material: material)

        model.validate
        expect(model.errors[:count]).to include 'must be greater than 0'
      end

      it 'is invalid if count is not an integer' do
        armor    = create(:canonical_armor)
        material = create(:canonical_material)
        model    = described_class.new(count: 1.3, canonical_armor: armor, canonical_material: material)

        model.validate
        expect(model.errors[:count]).to include 'must be an integer'
      end

      it 'is valid with a valid count' do
        armor    = create(:canonical_armor)
        material = create(:canonical_material)
        model    = described_class.new(count: 2, canonical_armor: armor, canonical_material: material)

        expect(model).to be_valid
      end
    end
  end
end
