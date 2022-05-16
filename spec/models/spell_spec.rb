# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spell, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'must be present' do
        spell = described_class.new

        spell.validate
        expect(spell.errors[:name]).to include "can't be blank"
      end

      it 'must be unique' do
        described_class.create!(name: 'Clairvoyance', school: 'Illusion', level: 'Novice', description: 'Something')
        spell = described_class.new(name: 'Clairvoyance')

        spell.validate
        expect(spell.errors[:name]).to include 'must be unique'
      end
    end

    describe 'school' do
      it 'must be present' do
        spell = described_class.new

        spell.validate
        expect(spell.errors[:school]).to include "can't be blank"
      end

      it 'must be a valid school of magic' do
        spell = described_class.new(name: 'Alternation')

        spell.validate
        expect(spell.errors[:school]).to include 'must be a valid school of magic'
      end
    end

    describe 'level' do
      it 'must be present' do
        spell = described_class.new

        spell.validate
        expect(spell.errors[:level]).to include "can't be blank"
      end

      it 'must be a valid level' do
        spell = described_class.new

        spell.validate
        expect(spell.errors[:level]).to include 'must be "Novice", "Apprentice", "Adept", "Expert", or "Master"'
      end
    end

    describe 'description' do
      it 'must be present' do
        spell = described_class.new

        spell.validate
        expect(spell.errors[:description]).to include "can't be blank"
      end
    end

    describe 'strength and strength_unit' do
      it 'is valid with both a strength and a strength_unit' do
        spell = described_class.new(
                  strength:      50,
                  strength_unit: 'point',
                  name:          'Fire Rune',
                  level:         'Adept',
                  school:        'Destruction',
                  description:   'Hello world',
                )

        expect(spell).to be_valid
      end

      it 'is valid with neither a strength nor a strength_unit' do
        spell = described_class.new(name: 'Clairvoyance', level: 'Novice', school: 'Illusion', description: 'Hello world')

        expect(spell).to be_valid
      end

      it 'is invalid with a strength but no strength_unit' do
        spell = described_class.new(strength: 50)
        spell.validate
        expect(spell.errors[:strength_unit]).to include 'must be present if strength is given'
      end

      it 'is invalid with a strength_unit but no strength' do
        spell = described_class.new(strength_unit: 'percentage')
        spell.validate
        expect(spell.errors[:strength]).to include 'must be present if strength unit is given'
      end

      it 'requires a valid strength_unit value' do
        spell = described_class.new(strength: 50, strength_unit: 'foo')
        spell.validate
        expect(spell.errors[:strength_unit]).to include 'must be "point", "percentage", or the "level" of affected targets'
      end
    end
  end

  describe 'class methods' do
    describe '::unique_identifier' do
      subject(:unique_identifier) { described_class.unique_identifier }

      it 'returns :name' do
        expect(unique_identifier).to eq :name
      end
    end
  end
end
