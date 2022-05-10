# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::JewelryItemsMaterial, type: :model do
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

    describe 'canonical jewelry item and canonical material' do
      it 'must form a unique combination' do
        create(:canonical_jewelry_items_material, canonical_jewelry_item: jewelry_item, canonical_material: material)
        model = described_class.new(canonical_jewelry_item: jewelry_item, canonical_material: material)

        model.validate
        expect(model.errors[:canonical_jewelry_item_id]).to include 'must form a unique combination with canonical material'
      end
    end
  end
end
