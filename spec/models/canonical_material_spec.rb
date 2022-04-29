# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalMaterial, type: :model do
  describe 'validations' do
    it 'is valid with a valid name and unit weight' do
      material = described_class.new(unit_weight: 7.0, name: 'bear pelt')

      expect(material).to be_valid
    end

    describe 'name' do
      it 'is invalid without a name' do
        material = described_class.new(unit_weight: 4.2)

        material.validate
        expect(material.errors[:name]).to include "can't be blank"
      end

      it 'is invalid with a duplicate name' do
        described_class.create!(name: 'foo', unit_weight: 34.0)
        material = described_class.new(name: 'foo', unit_weight: 34.0)

        material.validate
        expect(material.errors[:name]).to include 'has already been taken'
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
end
