# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Material, type: :model do
  describe 'validations' do
    it 'is valid with a valid name, item code, and unit weight' do
      material = build(:canonical_material, item_code: 'foo', unit_weight: 7.0, name: 'bear pelt')

      expect(material).to be_valid
    end

    describe 'name' do
      it 'is invalid without a name' do
        material = described_class.new(item_code: 'foo', unit_weight: 4.2)

        material.validate
        expect(material.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it 'is invalid without an item code' do
        material = described_class.new(name: 'foo', unit_weight: 1.5)

        material.validate
        expect(material.errors[:item_code]).to include "can't be blank"
      end

      it 'is invalid with a duplicate item code' do
        create(:canonical_material, item_code: 'foo')
        material = build(:canonical_material, item_code: 'foo')

        material.validate
        expect(material.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit_weight' do
      it 'is invalid without a unit weight' do
        material = described_class.new(name: 'foo')

        material.validate
        expect(material.errors[:unit_weight]).to include "can't be blank"
      end

      it 'is invalid with a non-numeric unit weight' do
        material = described_class.new(name: 'foo', unit_weight: 'bar')

        material.validate
        expect(material.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid without a negative unit weight' do
        material = described_class.new(name: 'foo', unit_weight: -4.0)

        material.validate
        expect(material.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end
  end

  describe 'default behavior' do
    it 'upcases item codes' do
      material = create(:canonical_material, item_code: 'abc123')
      expect(material.reload.item_code).to eq 'ABC123'
    end
  end

  describe 'class methods' do
    describe '::unique_identifier' do
      it 'returns :item_code' do
        expect(described_class.unique_identifier).to eq :item_code
      end
    end
  end
end
