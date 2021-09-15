# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe Property, type: :model do
  subject(:property) { described_class.new }

  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) do
    Rails.application.load_tasks
  end
  # rubocop:enable RSpec/BeforeAfterAll

  before do
    Rake::Task['canonical_models:populate:canonical_properties'].invoke
  end

  after do
    Rake::Task['canonical_models:populate:canonical_properties'].reenable
  end

  describe 'validations' do
    let(:game) { create(:game) }

    before do
      allow(Rails.logger).to receive(:error)
    end

    it 'is invalid without a game' do
      property.validate
      expect(property.errors[:game]).to eq ['must exist']
    end

    it 'is invalid without a canonical property' do
      property.validate
      expect(property.errors[:canonical_property]).to eq ['must exist']
    end

    it 'must have a valid name' do
      property.validate
      expect(property.errors[:name]).to eq ["can't be blank", "must be an ownable property in Skyrim, or the Arch-Mage's Quarters"]
    end

    it 'must have a valid hold' do
      property.validate
      expect(property.errors[:hold]).to eq ["can't be blank", 'must be one of the nine Skyrim holds, or Solstheim']
    end

    it 'only allows up to 10 per game', :aggregate_failures do
      CanonicalProperty.all.each do |canonical_property|
        game.properties.create!(
          canonical_property: canonical_property,
          name:               canonical_property.name,
          hold:               canonical_property.hold,
          city:               canonical_property.city,
        )
      end

      property.game = game
      property.name = 'Vlindrel Hall'
      property.hold = 'The Reach'
      property.validate
      expect(property.errors[:game]).to eq ['already has max number of ownable properties']
      expect(Rails.logger).to have_received(:error).with('Cannot create property "Vlindrel Hall" in hold "The Reach": this game already has 10 properties')
    end

    describe 'uniqueness' do
      let(:canonical_property) { CanonicalProperty.first }

      before do
        game.properties.create!(
          canonical_property: canonical_property,
          name:               canonical_property.name,
          hold:               canonical_property.hold,
          city:               canonical_property.city,
        )
      end

      it 'has a unique combination of game and canonical property' do
        property.game               = game
        property.canonical_property = canonical_property
        property.validate
        expect(property.errors[:canonical_property]).to eq ['must be unique per game']
      end

      it 'has a unique name per game' do
        property.game = game
        property.name = canonical_property.name
        property.validate
        expect(property.errors[:name]).to eq ['must be unique per game']
      end

      it 'has a unique hold per game' do
        property.game = game
        property.hold = canonical_property.hold
        property.validate
        expect(property.errors[:hold]).to eq ['must be unique per game']
      end
    end

    describe 'consistency with canonical property' do
      let(:canonical_property) { CanonicalProperty.find_by(name: 'Severin Manor') }

      it 'must have the same name, hold, and city as the canonical property' do
        property.canonical_property_id = canonical_property.id
        property.name                  = canonical_property.name
        property.hold                  = canonical_property.hold
        property.city                  = nil
        property.validate
        expect(property.errors[:base]).to eq ['property attributes must match attributes of a property that exists in Skyrim']
      end
    end

    describe 'arcane enchanter availability' do
      context 'when an arcane enchanter is not available at the given property' do
        let(:canonical_property) { CanonicalProperty.find_by(name: 'Breezehome') }

        it 'cannot have an arcane enchanter' do
          property.canonical_property_id = canonical_property.id
          property.has_arcane_enchanter  = true
          property.validate
          expect(property.errors[:has_arcane_enchanter]).to eq ['cannot be true because this property cannot have an arcane enchanter in Skyrim']
        end
      end

      context 'when an arcane enchanter is available at the given property' do
        let(:canonical_property) { CanonicalProperty.find_by(name: 'Lakeview Manor') }

        it 'can have an arcane enchanter' do
          property.canonical_property_id = canonical_property.id
          property.has_arcane_enchanter  = true
          property.validate
          expect(property.errors[:has_arcane_enchanter]).to be_blank
        end

        it "doesn't have to have an arcane enchanter" do
          property.canonical_property_id = canonical_property.id
          property.has_arcane_enchanter  = false
          property.validate
          expect(property.errors[:has_arcane_enchanter]).to be_blank
        end
      end
    end

    describe 'forge availability' do
      context 'when a forge is not available at the given property' do
        let(:canonical_property) { CanonicalProperty.find_by(name: 'Breezehome') }

        it 'cannot have a forge' do
          property.canonical_property_id = canonical_property.id
          property.has_forge             = true
          property.validate
          expect(property.errors[:has_forge]).to eq ['cannot be true because this property cannot have a forge in Skyrim']
        end
      end

      context 'when a forge is available at the given property' do
        let(:canonical_property) { CanonicalProperty.find_by(name: 'Lakeview Manor') }

        it 'can have a forge' do
          property.canonical_property_id = canonical_property.id
          property.has_forge             = true
          property.validate
          expect(property.errors[:has_forge]).to be_blank
        end

        it "doesn't have to have a forge" do
          property.canonical_property_id = canonical_property.id
          property.has_forge             = false
          property.validate
          expect(property.errors[:has_forge]).to be_blank
        end
      end
    end
  end
end
