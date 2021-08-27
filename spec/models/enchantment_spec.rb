# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enchantment, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid without a name' do
        enchantment = described_class.new(strength_unit: 'percentage', enchantable_items: %w[sword mace])

        enchantment.validate
        expect(enchantment.errors[:name]).to eq ["can't be blank"]
      end

      it 'requires a unique name' do
        described_class.create!(name: 'Absorb Health', strength_unit: 'point', enchantable_items: %w[battleaxe warhammer])

        enchantment = described_class.new(name: 'Absorb Health', strength_unit: 'percentage', enchantable_items: %w[sword mace greatsword])

        enchantment.validate
        expect(enchantment.errors[:name]).to eq ['must be unique']
      end
    end

    describe 'strength_unit' do
      it 'must be one of "point" or "percentage"' do
        enchantment = described_class.new

        enchantment.validate
        expect(enchantment.errors[:strength_unit]).to eq ["can't be blank", 'must be "point" or "percentage"']
      end
    end

    describe 'enchantable_items' do
      it 'needs to be one of the valid enchantable items' do
        enchantment = described_class.new(name: 'Fortify Archery', strength_unit: 'percentage', enchantable_items: %w[ring necklace foo])

        enchantment.validate

        expect(enchantment.errors[:enchantable_items]).to eq ['must consist of valid enchantable item types']
      end
    end
  end
end
