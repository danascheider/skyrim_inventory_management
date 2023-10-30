# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe Property, type: :model do
  let(:property) { described_class.new }

  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) do
    Rails.application.load_tasks
  end
  # rubocop:enable RSpec/BeforeAfterAll

  before do
    Rake::Task['canonical_models:sync:properties'].invoke
  end

  after do
    Rake::Task['canonical_models:sync:properties'].reenable
  end

  describe 'validations' do
    subject(:validate) { property.validate }

    let(:game) { create(:game) }

    before do
      allow(Rails.logger).to receive(:error)
      allow_any_instance_of(HomesteadValidator)
        .to receive(:validate)
              .and_call_original
    end

    it 'is invalid without a game' do
      validate
      expect(property.errors[:game]).to include 'must exist'
    end

    it 'is invalid without a canonical property' do
      validate
      expect(property.errors[:base]).to include "doesn't match any ownable property that exists in Skyrim"
    end

    it 'must have a name' do
      validate
      expect(property.errors[:name]).to include "can't be blank"
    end

    it 'must have a valid name' do
      property.name = 'Camelot'
      validate
      expect(property.errors[:name]).to include "must be an ownable property in Skyrim, or the Arch-Mage's Quarters"
    end

    it 'must have a hold' do
      validate
      expect(property.errors[:hold]).to include "can't be blank"
    end

    it 'must have a valid hold' do
      property.hold = 'Leyawiin'
      validate
      expect(property.errors[:hold]).to include 'must be one of the nine Skyrim holds, or Solstheim'
    end

    it 'only allows up to 10 per game', :aggregate_failures do
      Canonical::Property.all.find_each do |canonical_property|
        game.properties.create!(
          canonical_property:,
          name: canonical_property.name,
          hold: canonical_property.hold,
          city: canonical_property.city,
        )
      end

      property.game = game
      property.name = 'Vlindrel Hall'
      property.hold = 'The Reach'
      validate
      expect(property.errors[:game]).to include 'already has max number of ownable properties'
      expect(Rails.logger)
        .to have_received(:error)
              .with('Cannot create property "Vlindrel Hall" in hold "The Reach": this game already has 10 properties')
    end

    it 'calls the HomesteadValidator' do
      expect_any_instance_of(HomesteadValidator)
        .to receive(:validate)
              .with(property)
              .and_call_original

      validate
    end

    describe 'uniqueness' do
      let(:canonical_property) { Canonical::Property.first }

      before do
        game.properties.create!(
          canonical_property:,
          name: canonical_property.name,
          hold: canonical_property.hold,
          city: canonical_property.city,
        )
      end

      it 'has a unique combination of game and canonical property' do
        property.game = game
        property.canonical_property = canonical_property
        validate
        expect(property.errors[:canonical_property]).to include 'must be unique per game'
      end

      it 'has a unique name per game' do
        property.game = game
        property.name = canonical_property.name
        validate
        expect(property.errors[:name]).to include 'must be unique per game'
      end

      it 'has a unique hold per game' do
        property.game = game
        property.hold = canonical_property.hold
        validate
        expect(property.errors[:hold]).to include 'must be unique per game'
      end
    end

    describe 'arcane enchanter availability' do
      context 'when an arcane enchanter is not available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Breezehome') }

        it 'cannot have an arcane enchanter' do
          property.canonical_property_id = canonical_property.id
          property.has_arcane_enchanter = true
          validate
          expect(property.errors[:has_arcane_enchanter]).to include 'cannot be true because this property cannot have an arcane enchanter in Skyrim'
        end
      end

      context 'when an arcane enchanter is available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Lakeview Manor') }

        it 'can have an arcane enchanter' do
          property.canonical_property_id = canonical_property.id
          property.has_arcane_enchanter = true
          validate
          expect(property.errors[:has_arcane_enchanter]).to be_blank
        end

        it "doesn't have to have an arcane enchanter" do
          property.canonical_property_id = canonical_property.id
          property.has_arcane_enchanter = false
          validate
          expect(property.errors[:has_arcane_enchanter]).to be_blank
        end
      end
    end

    describe 'forge availability' do
      context 'when a forge is not available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Breezehome') }

        it 'cannot have a forge' do
          property.canonical_property_id = canonical_property.id
          property.has_forge = true
          validate
          expect(property.errors[:has_forge]).to include 'cannot be true because this property cannot have a forge in Skyrim'
        end
      end

      context 'when a forge is available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Lakeview Manor') }

        it 'can have a forge' do
          property.canonical_property_id = canonical_property.id
          property.has_forge = true
          validate
          expect(property.errors[:has_forge]).to be_blank
        end

        it "doesn't have to have a forge" do
          property.canonical_property_id = canonical_property.id
          property.has_forge = false
          validate
          expect(property.errors[:has_forge]).to be_blank
        end
      end
    end

    describe 'apiary availability' do
      context 'when an apiary is not available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Breezehome') }

        it 'cannot have an apiary' do
          property.canonical_property_id = canonical_property.id
          property.has_apiary = true
          validate
          expect(property.errors[:has_apiary]).to include 'cannot be true because this property cannot have an apiary in Skyrim'
        end
      end

      context 'when an apiary is available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Lakeview Manor') }

        it 'can have an apiary' do
          property.canonical_property_id = canonical_property.id
          property.has_apiary = true
          validate
          expect(property.errors[:has_apiary]).to be_blank
        end

        it "doesn't have to have an apiary" do
          property.canonical_property_id = canonical_property.id
          property.has_apiary = false
          validate
          expect(property.errors[:has_apiary]).to be_blank
        end
      end
    end

    describe 'grain mill availability' do
      context 'when a grain mill is not available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Lakeview Manor') }

        it 'cannot have a grain mill' do
          property.canonical_property_id = canonical_property.id
          property.has_grain_mill = true
          validate
          expect(property.errors[:has_grain_mill]).to include 'cannot be true because this property cannot have a grain mill in Skyrim'
        end
      end

      context 'when a grain mill is available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Heljarchen Hall') }

        it 'can have a grain mill' do
          property.canonical_property_id = canonical_property.id
          property.has_grain_mill = true
          validate
          expect(property.errors[:has_grain_mill]).to be_blank
        end

        it "doesn't have to have a grain mill" do
          property.canonical_property_id = canonical_property.id
          property.has_grain_mill = false
          validate
          expect(property.errors[:has_grain_mill]).to be_blank
        end
      end
    end

    describe 'fish hatchery availability' do
      context 'when a fish hatchery is not available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Lakeview Manor') }

        it 'cannot have a fish hatchery' do
          property.canonical_property_id = canonical_property.id
          property.has_fish_hatchery = true
          validate
          expect(property.errors[:has_fish_hatchery]).to include 'cannot be true because this property cannot have a fish hatchery in Skyrim'
        end
      end

      context 'when a fish hatchery is available at the given property' do
        let(:canonical_property) { Canonical::Property.find_by(name: 'Windstad Manor') }

        it 'can have a fish hatchery' do
          property.canonical_property_id = canonical_property.id
          property.has_fish_hatchery = true
          validate
          expect(property.errors[:has_fish_hatchery]).to be_blank
        end

        it "doesn't have to have a fish hatchery" do
          property.canonical_property_id = canonical_property.id
          property.has_fish_hatchery = false
          validate
          expect(property.errors[:has_fish_hatchery]).to be_blank
        end
      end
    end
  end

  describe 'setting a canonical model' do
    subject(:validate) { property.validate }

    context 'when a canonical property is already assigned' do
      let(:property) { build(:property, name: 'Vlindrel Hall', canonical_property:) }
      let(:canonical_property) { Canonical::Property.find_by(name: 'Vlindrel Hall') }

      it "doesn't change the canonical property" do
        expect { validate }
          .not_to change(property, :canonical_property)
      end
    end

    context 'when there is a matching canonical property' do
      let(:property) { build(:property, name: 'vlindrel hall') }
      let!(:canonical_property) { Canonical::Property.find_by(name: 'Vlindrel Hall') }

      it 'sets the canonical property', :aggregate_failures do
        validate
        expect(property.canonical_property).to eq canonical_property
      end
    end
  end

  describe 'setting values from the canonical model' do
    subject(:validate) { property.validate }

    context 'when a canonical model is present' do
      let(:property) { build(:property, name: 'hjerim') }

      it 'sets the property name, city, and hold', :aggregate_failures do
        validate
        expect(property.name).to eq 'Hjerim'
        expect(property.city).to eq 'Windhelm'
        expect(property.hold).to eq 'Eastmarch'
      end
    end
  end
end
