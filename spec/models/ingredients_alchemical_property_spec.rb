# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngredientsAlchemicalProperty, type: :model do
  before do
    create(:canonical_ingredient)
  end

  describe 'validations' do
    describe 'number of records per ingredient' do
      let!(:ingredient) { create(:ingredient, :with_alchemical_properties) }

      it 'cannot have more than 4 records corresponding to one ingredient' do
        # Since the alchemical properties are added in FactoryBot's after(:create) hook,
        # the ingredient needs to be reloaded before Rails/RSpec will know about them.
        ingredient.reload

        new_association = build(:ingredients_alchemical_property, ingredient:)

        new_association.validate
        expect(new_association.errors[:ingredient]).to include 'already has 4 alchemical properties'
      end
    end

    describe 'priority' do
      let(:ingredient) { create(:ingredient) }

      it "can't be less than 1" do
        model = build(:ingredients_alchemical_property, priority: 0)

        model.validate
        expect(model.errors[:priority]).to include 'must be greater than or equal to 1'
      end

      it "can't be more than 4" do
        model = build(:ingredients_alchemical_property, priority: 5)

        model.validate
        expect(model.errors[:priority]).to include 'must be less than or equal to 4'
      end

      it 'must be an integer' do
        model = build(:ingredients_alchemical_property, priority: 3.2)

        model.validate
        expect(model.errors[:priority]).to include 'must be an integer'
      end

      describe 'uniqueness' do
        before do
          create(
            :ingredients_alchemical_property,
            priority: 1,
            ingredient:,
          )
        end

        it 'must be unique per ingredient' do
          model = build(
            :ingredients_alchemical_property,
            priority: 1,
            ingredient:,
          )

          model.validate
          expect(model.errors[:priority]).to include 'must be unique per ingredient'
        end

        it "doesn't have to be globally unique" do
          model = build(:ingredients_alchemical_property, priority: 1)

          expect(model).to be_valid
        end
      end
    end

    describe 'strength_modifier' do
      it 'must be greater than zero' do
        model = build(:ingredients_alchemical_property, strength_modifier: 0)

        model.validate
        expect(model.errors[:strength_modifier]).to include 'must be greater than 0'
      end
    end

    describe 'duration_modifier' do
      it 'must be greater than zero' do
        model = build(:ingredients_alchemical_property, duration_modifier: 0)

        model.validate
        expect(model.errors[:duration_modifier]).to include 'must be greater than 0'
      end
    end

    describe 'alchemical_property_id' do
      it 'must be unique per ingredient' do
        existing_model = create(:ingredients_alchemical_property)
        model = build(
          :ingredients_alchemical_property,
          ingredient: existing_model.ingredient,
          alchemical_property: existing_model.alchemical_property,
          priority: 1,
        )

        model.validate
        expect(model.errors[:alchemical_property_id]).to include 'must form a unique combination with ingredient'
      end
    end
  end
end
