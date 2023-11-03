# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PotionsAlchemicalProperty, type: :model do
  describe 'validations' do
    let(:model) { build(:potions_alchemical_property) }

    describe 'unique combination of potion and alchemical property' do
      let(:model) { create(:potions_alchemical_property) }
      let(:non_unique_model) do
        build(
          :potions_alchemical_property,
          potion: model.potion,
          alchemical_property: model.alchemical_property,
        )
      end

      it 'is invalid with a non-unique combination of potion and alchemical property' do
        non_unique_model.validate
        expect(non_unique_model.errors[:alchemical_property_id])
          .to include 'must form a unique combination with potion'
      end
    end

    describe '#strength' do
      it 'can be blank' do
        model.strength = nil
        model.validate

        expect(model.errors[:strength]).to be_empty
      end

      it 'is invalid with a non-numeric strength' do
        model.strength = 'foobar'
        model.validate

        expect(model.errors[:strength])
          .to include 'is not a number'
      end

      it 'is invalid with a non-integer strength' do
        model.strength = 2.3
        model.validate

        expect(model.errors[:strength])
          .to include 'must be an integer'
      end

      it 'is invalid with a strength of 0 or less' do
        model.strength = -1
        model.validate

        expect(model.errors[:strength])
          .to include 'must be greater than 0'
      end
    end

    describe '#duration' do
      it 'can be blank' do
        model.duration = nil
        model.validate

        expect(model.errors[:duration]).to be_empty
      end

      it 'is invalid with a non-numeric duration' do
        model.duration = 'foobar'
        model.validate

        expect(model.errors[:duration])
          .to include 'is not a number'
      end

      it 'is invalid with a non-integer duration' do
        model.duration = 2.3
        model.validate

        expect(model.errors[:duration])
          .to include 'must be an integer'
      end

      it 'is invalid with a duration of 0 or less' do
        model.duration = -1
        model.validate

        expect(model.errors[:duration])
          .to include 'must be greater than 0'
      end
    end

    describe 'alchemical effects' do
      let(:potion) { create(:potion) }
      let(:model) { build(:potions_alchemical_property, potion:) }

      context 'when the potion has fewer than 4 effects' do
        before do
          create_list(
            :potions_alchemical_property,
            3,
            potion:,
          )

          potion.reload
        end

        it 'is valid' do
          expect(model).to be_valid
        end
      end

      context 'when the potion already has 4 or more effects' do
        before do
          create_list(
            :potions_alchemical_property,
            4,
            potion:,
          )

          potion.reload
        end

        it 'is invalid' do
          model.validate

          expect(model.errors[:potion]).to include 'can have a maximum of 4 effects'
        end
      end
    end
  end
end
