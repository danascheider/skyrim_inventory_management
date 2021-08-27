# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spell, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'must be present' do
        spell = described_class.new
        spell.validate
        expect(spell.errors[:name]).to eq ["can't be blank"]
      end

      it 'must be unique' do
        described_class.create!(name: 'Clairvoyance', school: 'Illusion', description: 'Something')

        spell = described_class.new(name: 'Clairvoyance')
        spell.validate
        expect(spell.errors[:name]).to eq ['must be unique']
      end
    end

    describe 'school' do
      it 'must be a valid school of magic' do
        spell = described_class.new
        spell.validate
        expect(spell.errors[:school]).to eq ["can't be blank", 'must be a valid school of magic']
      end
    end

    describe 'description' do
      it 'must be present' do
        spell = described_class.new
        spell.validate
        expect(spell.errors[:description]).to eq ["can't be blank"]
      end
    end
  end
end
