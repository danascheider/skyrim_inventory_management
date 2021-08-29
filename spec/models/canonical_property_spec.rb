# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalProperty, type: :model do
  subject(:property) { described_class.new }

  describe 'validations' do
    it 'must have a valid name' do
      property.validate
      expect(property.errors[:name]).to eq ["can't be blank", "must be an ownable property in Skyrim, or the Arch-Mage's Quarters"]
    end

    it 'must have a unique name' do
      described_class.create!(name: 'Breezehome', hold: 'Whiterun')
      property.name = 'Breezehome'
      property.validate
      expect(property.errors[:name]).to eq ['must be unique']
    end

    it 'must have a valid hold' do
      property.validate
      expect(property.errors[:hold]).to eq ["can't be blank", 'must be one of the nine Skyrim holds, or Solstheim']
    end

    it 'must have a unique hold' do
      described_class.create!(name: 'Heljarchen Hall', hold: 'The Pale')
      property.hold = 'The Pale'
      property.validate
      expect(property.errors[:hold]).to eq ['must be unique']
    end

    it 'must have a valid city' do
      property.city = 'Tampa'
      property.validate
      expect(property.errors[:city]).to eq ['must be a Skyrim city in which an ownable property is located']
    end

    it 'must have a unique city (if not null)' do
      described_class.create!(name: 'Proudspire Manor', hold: 'Haafingar', city: 'Solitude')
      property.city = 'Solitude'
      property.validate
      expect(property.errors[:city]).to eq ['must be unique if present']
    end

    it 'can have a blank city' do
      property.validate
      expect(property.errors[:city]).to be_blank
    end
  end

  describe 'count limit' do
    before do
      allow(Rails.logger).to receive(:error)

      names_and_holds = described_class::VALID_NAMES.zip(described_class::VALID_HOLDS)

      names_and_holds.each do |pair|
        described_class.find_or_create_by!(name: pair[0], hold: pair[1])
      end
    end

    it 'adds a validation error to the base' do
      property.name = 'Breezehome'
      property.hold = 'Whiterun'
      property.validate
      expect(property.errors[:base]).to eq ['cannot create a new canonical property as there are already 10']
    end

    it 'logs an error' do
      property = described_class.new(name: 'Breezehome', hold: 'Whiterun')
      property.validate
      expect(Rails.logger).to have_received(:error).with('Cannot create canonical property "Breezehome" in hold "Whiterun": there are already 10 canonical properties')
    end
  end
end
