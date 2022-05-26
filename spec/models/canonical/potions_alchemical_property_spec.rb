# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::PotionsAlchemicalProperty, type: :model do
  describe 'validations' do
    describe 'canonical potion and alchemical property' do
      it 'must form a unique combination' do
        model1 = create(:canonical_potions_alchemical_property)
        model2 = build(:canonical_potions_alchemical_property, potion: model1.potion, alchemical_property: model1.alchemical_property)

        model2.validate
        expect(model2.errors[:alchemical_property_id]).to include 'must form a unique combination with canonical potion'
      end
    end

    describe 'strength' do
      it 'can be blank' do
        model = build(:canonical_potions_alchemical_property, strength: nil)

        expect(model).to be_valid
      end

      it 'must be a number' do
        model = build(:canonical_potions_alchemical_property, strength: 'foo')

        model.validate
        expect(model.errors[:strength]).to include 'is not a number'
      end

      it 'must be an integer' do
        model = build(:canonical_potions_alchemical_property, strength: 3.14159)

        model.validate
        expect(model.errors[:strength]).to include 'must be an integer'
      end

      it 'must be greater than zero' do
        model = build(:canonical_potions_alchemical_property, strength: 0)

        model.validate
        expect(model.errors[:strength]).to include 'must be greater than 0'
      end
    end

    describe 'duration' do
      it 'can be blank' do
        model = build(:canonical_potions_alchemical_property, duration: nil)

        expect(model).to be_valid
      end

      it 'must be a number' do
        model = build(:canonical_potions_alchemical_property, duration: 'foo')

        model.validate
        expect(model.errors[:duration]).to include 'is not a number'
      end

      it 'must be an integer' do
        model = build(:canonical_potions_alchemical_property, duration: 3.14159)

        model.validate
        expect(model.errors[:duration]).to include 'must be an integer'
      end

      it 'must be greater than zero' do
        model = build(:canonical_potions_alchemical_property, duration: 0)

        model.validate
        expect(model.errors[:duration]).to include 'must be greater than 0'
      end
    end
  end
end
