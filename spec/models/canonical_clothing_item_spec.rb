# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalClothingItem, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid without a name' do
        item = described_class.new

        item.validate
        expect(item.errors[:name]).to include "can't be blank"
      end

      it 'is invalid with a non-unique name' do
        create(:canonical_clothing_item, name: 'foo')
        item = described_class.new(name: 'foo')

        item.validate
        expect(item.errors[:name]).to include 'has already been taken'
      end

      it 'is valid with a valid name' do
        item = described_class.new(name: 'foo', unit_weight: 2.0, body_slot: 'feet')

        expect(item).to be_valid
      end
    end

    describe 'unit_weight' do
      it 'is invalid with a non-numeric unit weight' do
        item = described_class.new(name: 'foo', unit_weight: 'bar')

        item.validate
        expect(item.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid with a negative unit weight' do
        item = described_class.new(name: 'foo', unit_weight: -34)

        item.validate
        expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end

      it 'is valid with a positive decimal unit weight value' do
        item = described_class.new(name: 'foo', unit_weight: 7.0, body_slot: 'hands')

        expect(item).to be_valid
      end
    end

    describe 'body_slot' do
      it 'is invalid without a body_slot' do
        item = described_class.new(name: 'foo', unit_weight: 2.0)

        item.validate
        expect(item.errors[:body_slot]).to include "can't be blank"
      end

      it 'is invalid with an invalid body_slot value' do
        item = described_class.new(name: 'foo', unit_weight: 2.0, body_slot: 'bar')

        item.validate
        expect(item.errors[:body_slot]).to include 'must be "head", "hands", "body", or "feet"'
      end

      it 'is valid with a valid body_slot value' do
        item = described_class.new(name: 'foo', unit_weight: 14.2, body_slot: 'shield')

        expect(item).to be_valid
      end
    end
  end
end
