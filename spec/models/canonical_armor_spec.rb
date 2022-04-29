# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalArmor, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid without a name' do
        armor = described_class.new(weight: 'heavy armor', unit_weight: 1.0, body_slot: 'body')

        armor.validate
        expect(armor.errors[:name]).to include "can't be blank"
      end
    end

    describe 'weight' do
      it 'is invalid without a weight' do
        armor = described_class.new(name: 'fur armor', unit_weight: 2.5, body_slot: 'head')

        armor.validate
        expect(armor.errors[:weight]).to include "can't be blank"
      end

      it 'is invalid with an invalid weight value' do
        armor = described_class.new(name: 'fur armor', unit_weight: 2.5, body_slot: 'head', weight: 'medium armor')

        armor.validate
        expect(armor.errors[:weight]).to include 'must be "light armor" or "heavy armor"'
      end
    end

    describe 'body_slot' do
      it 'is invalid without a body slot' do
        armor = described_class.new(name: 'fur armor', weight: 'light armor', unit_weight: 47.0)

        armor.validate
        expect(armor.errors[:body_slot]).to include "can't be blank"
      end

      it 'is invalid without a valid body slot value' do
        armor = described_class.new(name: 'fur armor', weight: 'light armor', unit_weight: 47.0, body_slot: 'foo')

        armor.validate
        expect(armor.errors[:body_slot]).to include 'must be "head", "body", "hands", "feet", or "shield"'
      end

      it 'is valid with a valid body slot' do
        armor = described_class.new(name: 'fur armor', weight: 'light armor', unit_weight: 47.0, body_slot: 'feet')

        expect(armor).to be_valid
      end
    end

    describe 'unit_weight' do
      it 'is invalid without a unit weight' do
        armor = described_class.new(name: 'steel helmet', weight: 'heavy armor', body_slot: 'head')

        armor.validate
        expect(armor.errors[:unit_weight]).to include "can't be blank"
      end

      it 'is invalid with a non-numeric unit weight' do
        armor = described_class.new(name: 'steel helmet', weight: 'heavy armor', body_slot: 'head', unit_weight: 'foo')

        armor.validate
        expect(armor.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid with a negative unit weight' do
        armor = described_class.new(name: 'steel helmet', weight: 'heavy armor', body_slot: 'head', unit_weight: -2.4)

        armor.validate
        expect(armor.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end

      it 'is valid with a valid unit weight' do
        armor = described_class.new(name: 'steel helmet', weight: 'heavy armor', body_slot: 'head', unit_weight: 2.4)

        expect(armor).to be_valid
      end
    end
  end
end
