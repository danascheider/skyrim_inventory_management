# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlchemicalProperty, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'must be present' do
        model = build(:alchemical_property, name: nil)

        model.validate
        expect(model.errors[:name]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:alchemical_property, name: 'Restore Health', strength_unit: 'point')
        model = build(:alchemical_property, name: 'Restore Health')

        model.validate
        expect(model.errors[:name]).to include 'must be unique'
      end
    end

    describe 'description' do
      it "can't be blank" do
        model = build(:alchemical_property, description: nil)

        model.validate
        expect(model.errors[:description]).to include "can't be blank"
      end
    end

    describe 'strength_unit' do
      it "isn't required" do
        model = build(:alchemical_property, strength_unit: nil)

        model.validate
        expect(model.errors[:strength_unit]).to be_empty
      end

      it 'must be one of "point" or "percentage"' do
        model = build(:alchemical_property, strength_unit: 'Foobar')

        model.validate
        expect(model.errors[:strength_unit]).to include 'must be "point", "percentage", or the "level" of affected targets'
      end
    end

    describe 'effect type' do
      it 'is valid if "potion"' do
        model = build(:alchemical_property, effect_type: 'potion')
        expect(model).to be_valid
      end

      it 'is valid if "poison"' do
        model = build(:alchemical_property, effect_type: 'poison')
        expect(model).to be_valid
      end

      it "can't be blank" do
        model = build(:alchemical_property, effect_type: nil)

        model.validate
        expect(model.errors[:effect_type]).to include "can't be blank"
      end

      it "can't be another value" do
        model = build(:alchemical_property, effect_type: 'mixed')

        model.validate
        expect(model.errors[:effect_type]).to include 'must be "potion" or "poison"'
      end
    end
  end

  describe 'class methods' do
    describe '::unique_identifier' do
      it 'returns :name' do
        expect(described_class.unique_identifier).to eq :name
      end
    end
  end
end
