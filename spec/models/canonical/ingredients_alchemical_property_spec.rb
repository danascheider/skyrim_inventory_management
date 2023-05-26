# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::IngredientsAlchemicalProperty, type: :model do
  describe 'validations' do
    describe 'number of records per ingredient' do
      let!(:ingredient) { create(:canonical_ingredient, :with_alchemical_properties) }

      it 'cannot have more than 4 records corresponding to one ingredient' do
        # Since the alchemical properties are added in FactoryBot's after(:create) hook,
        # the ingredient needs to be reloaded before Rails/RSpec will know about them.
        ingredient.reload

        new_association = build(:canonical_ingredients_alchemical_property, ingredient:)

        new_association.validate
        expect(new_association.errors[:ingredient]).to include 'already has 4 alchemical properties'
      end
    end

    describe 'priority' do
      describe 'uniqueness' do
        let(:ingredient) { create(:canonical_ingredient) }

        before do
          create(
            :canonical_ingredients_alchemical_property,
            priority: 1,
            ingredient:,
          )
        end

        it 'must be unique per ingredient' do
          model = build(
            :canonical_ingredients_alchemical_property,
            priority: 1,
            ingredient:,
          )

          model.validate
          expect(model.errors[:priority]).to include 'must be unique per ingredient'
        end

        it "isn't required to be globally unique" do
          model = build(:canonical_ingredients_alchemical_property, priority: 1)

          expect(model).to be_valid
        end
      end

      it "can't be less than 1" do
        model = build(:canonical_ingredients_alchemical_property, priority: 0)

        model.validate
        expect(model.errors[:priority]).to include 'must be greater than or equal to 1'
      end

      it "can't be more than 4" do
        model = build(:canonical_ingredients_alchemical_property, priority: 5)

        model.validate
        expect(model.errors[:priority]).to include 'must be less than or equal to 4'
      end

      it 'must be an integer' do
        model = build(:canonical_ingredients_alchemical_property, priority: 1.5)

        model.validate
        expect(model.errors[:priority]).to include 'must be an integer'
      end
    end

    describe 'strength_modifier' do
      it 'must be greater than zero' do
        model = build(:canonical_ingredients_alchemical_property, strength_modifier: 0)

        model.validate
        expect(model.errors[:strength_modifier]).to include 'must be greater than 0'
      end
    end

    describe 'duration_modifier' do
      it 'must be greater than zero' do
        model = build(:canonical_ingredients_alchemical_property, duration_modifier: 0)

        model.validate
        expect(model.errors[:duration_modifier]).to include 'must be greater than 0'
      end
    end

    describe 'alchemical_property_id' do
      it 'must be unique per ingredient' do
        existing_model = create(:canonical_ingredients_alchemical_property)
        model = build(
          :canonical_ingredients_alchemical_property,
          ingredient: existing_model.ingredient,
          alchemical_property: existing_model.alchemical_property,
          priority: 1,
        )

        model.validate
        expect(model.errors[:alchemical_property_id]).to include 'must form a unique combination with canonical ingredient'
      end
    end
  end
end
