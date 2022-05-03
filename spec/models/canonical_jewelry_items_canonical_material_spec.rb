# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalJewelryItemsCanonicalMaterial, type: :model do
  describe 'validations' do
    subject(:model) { described_class.new(canonical_jewelry_item: jewelry_item, canonical_material: material) }

    let(:jewelry_item) { create(:canonical_jewelry_item) }
    let(:material)     { create(:canonical_material) }

    describe 'quantity' do
      it 'is invalid with a quantity less than 1' do
        model.quantity = 0

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end

      it 'is invalid with a non-integer quantity' do
        model.quantity = 1.3

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end

      it 'is valid with an integer quantity of at least 1' do
        model.quantity = 3

        expect(model).to be_valid
      end
    end
  end
end
