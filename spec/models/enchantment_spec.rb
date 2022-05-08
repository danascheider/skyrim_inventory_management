# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enchantment, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid without a name' do
        enchantment = described_class.new(strength_unit: 'percentage', enchantable_items: %w[sword mace])

        enchantment.validate
        expect(enchantment.errors[:name]).to include "can't be blank"
      end

      it 'requires a unique name' do
        described_class.create!(name: 'Absorb Health', strength_unit: 'point', enchantable_items: %w[battleaxe warhammer])

        enchantment = described_class.new(name: 'Absorb Health', strength_unit: 'percentage', enchantable_items: %w[sword mace greatsword])

        enchantment.validate
        expect(enchantment.errors[:name]).to include 'must be unique'
      end
    end

    describe 'school' do
      it 'has to be a valid school of magic' do
        enchantment = described_class.new(school: 'Foo')

        enchantment.validate
        expect(enchantment.errors[:school]).to include 'must be a valid school of magic'
      end
    end

    describe 'strength_unit' do
      it 'must be "point", "percentage", "second", or "level"' do
        enchantment = described_class.new(strength_unit: 'foobar')

        enchantment.validate
        expect(enchantment.errors[:strength_unit]).to include 'must be "point", "percentage", "second", or the "level" of affected characters'
      end

      it 'can be blank' do
        enchantment = described_class.new

        enchantment.validate
        expect(enchantment.errors[:strength_unit]).to be_blank
      end
    end

    describe 'enchantable_items' do
      it 'needs to be one of the valid enchantable items' do
        enchantment = described_class.new(name: 'Fortify Archery', strength_unit: 'percentage', enchantable_items: %w[ring necklace foo])

        enchantment.validate

        expect(enchantment.errors[:enchantable_items]).to include 'must consist of valid enchantable item types'
      end
    end
  end
end
