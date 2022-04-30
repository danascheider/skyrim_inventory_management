# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalJewelryItemsCanonicalMaterial, type: :model do
  describe 'validations' do
    subject(:model) { described_class.new(canonical_jewelry_item: jewelry_item, canonical_material: material) }

    let(:jewelry_item) { create(:canonical_jewelry_item) }
    let(:material)     { create(:canonical_material) }

    describe 'count' do
      it 'is invalid with a count less than 1' do
        model.count = 0

        model.validate
        expect(model.errors[:count]).to include 'must be greater than 0'
      end

      it 'is invalid with a non-integer count' do
        model.count = 1.3

        model.validate
        expect(model.errors[:count]).to include 'must be an integer'
      end

      it 'is valid with an integer count of at least 1' do
        model.count = 3

        expect(model).to be_valid
      end
    end
  end
end
