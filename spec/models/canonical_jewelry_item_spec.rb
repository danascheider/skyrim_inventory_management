# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalJewelryItem, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid with no name' do
        item = described_class.new(jewelry_type: 'amulet', unit_weight: 1.0)

        item.validate
        expect(item.errors[:name]).to include "can't be blank"
      end

      it 'is invalid with a non-unique name' do
        create(:canonical_jewelry_item, name: 'foo')
        item = described_class.new(name: 'foo', jewelry_type: 'amulet', unit_weight: 1.0)

        item.validate
        expect(item.errors[:name]).to include 'has already been taken'
      end

      it 'is valid with a unique name' do
        item = described_class.new(name: 'foo', jewelry_type: 'amulet', unit_weight: 1.0)

        expect(item).to be_valid
      end
    end

    describe 'jewelry_type' do
      it 'is invalid without a jewelry_type' do
        item = described_class.new(name: 'foo', unit_weight: 1.0)

        item.validate
        expect(item.errors[:jewelry_type]).to include "can't be blank"
      end

      it 'is invalid with an invalid jewelry_type' do
        item = described_class.new(name: 'foo', unit_weight: 1.0, jewelry_type: 'bar')

        item.validate
        expect(item.errors[:jewelry_type]).to include 'must be "ring", "circlet", or "amulet"'
      end

      it 'is valid with a valid jewelry_type' do
        item = described_class.new(name: 'foo', unit_weight: 1.0, jewelry_type: 'circlet')

        expect(item).to be_valid
      end
    end

    describe 'unit_weight' do
      it 'is invalid without a unit weight' do
        item = described_class.new(name: 'foo', jewelry_type: 'ring')

        item.validate
        expect(item.errors[:unit_weight]).to include "can't be blank"
      end

      it 'is invalid with a non-numeric unit weight' do
        item = described_class.new(name: 'foo', unit_weight: 'bar', jewelry_type: 'circlet')

        item.validate
        expect(item.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid with a negative unit weight' do
        item = described_class.new(name: 'foo', unit_weight: -4.3, jewelry_type: 'amulet')

        item.validate
        expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end
  end
end
