# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PotionsAlchemicalProperty, type: :model do
  describe 'validations' do
    let(:potions_alchemical_property) { build(:potions_alchemical_property) }

    describe 'unique combination of potion and alchemical property' do
      let(:potions_alchemical_property) { create(:potions_alchemical_property) }
      let(:non_unique_pap) do
        build(
          :potions_alchemical_property,
          potion: potions_alchemical_property.potion,
          alchemical_property: potions_alchemical_property.alchemical_property,
        )
      end

      it 'is invalid with a non-unique combination of potion and alchemical property' do
        non_unique_pap.validate
        expect(non_unique_pap.errors[:alchemical_property_id])
          .to include 'must form a unique combination with potion'
      end
    end

    describe '#strength' do
      it 'can be blank' do
        potions_alchemical_property.strength = nil
        potions_alchemical_property.validate

        expect(potions_alchemical_property.errors[:strength]).to be_empty
      end

      it 'is invalid with a non-numeric strength' do
        potions_alchemical_property.strength = 'foobar'
        potions_alchemical_property.validate

        expect(potions_alchemical_property.errors[:strength])
          .to include 'is not a number'
      end

      it 'is invalid with a non-integer strength' do
        potions_alchemical_property.strength = 2.3
        potions_alchemical_property.validate

        expect(potions_alchemical_property.errors[:strength])
          .to include 'must be an integer'
      end

      it 'is invalid with a strength of 0 or less' do
        potions_alchemical_property.strength = -1
        potions_alchemical_property.validate

        expect(potions_alchemical_property.errors[:strength])
          .to include 'must be greater than 0'
      end
    end

    describe '#duration' do
      it 'can be blank' do
        potions_alchemical_property.duration = nil
        potions_alchemical_property.validate

        expect(potions_alchemical_property.errors[:duration]).to be_empty
      end

      it 'is invalid with a non-numeric duration' do
        potions_alchemical_property.duration = 'foobar'
        potions_alchemical_property.validate

        expect(potions_alchemical_property.errors[:duration])
          .to include 'is not a number'
      end

      it 'is invalid with a non-integer duration' do
        potions_alchemical_property.duration = 2.3
        potions_alchemical_property.validate

        expect(potions_alchemical_property.errors[:duration])
          .to include 'must be an integer'
      end

      it 'is invalid with a duration of 0 or less' do
        potions_alchemical_property.duration = -1
        potions_alchemical_property.validate

        expect(potions_alchemical_property.errors[:duration])
          .to include 'must be greater than 0'
      end
    end
  end
end
