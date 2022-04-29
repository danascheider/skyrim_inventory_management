# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalClothingItem, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid without a name' do
        item = described_class.new

        item.validate
        expect(item.errors[:name]).to eq ["can't be blank"]
      end

      it 'is invalid with a non-unique name' do
        create(:canonical_clothing_item, name: 'foo')
        item = described_class.new(name: 'foo')

        item.validate
        expect(item.errors[:name]).to eq ['has already been taken']
      end

      it 'is valid with a valid name' do
        item = described_class.new(name: 'foo')

        expect(item).to be_valid
      end
    end

    describe 'unit_weight' do
      it 'is invalid with a non-numeric unit weight' do
        item = described_class.new(name: 'foo', unit_weight: 'bar')

        item.validate
        expect(item.errors[:unit_weight]).to eq ['is not a number']
      end

      it 'is invalid with a negative unit weight' do
        item = described_class.new(name: 'foo', unit_weight: -34)

        item.validate
        expect(item.errors[:unit_weight]).to eq ['must be greater than or equal to 0']
      end
    end
  end
end
