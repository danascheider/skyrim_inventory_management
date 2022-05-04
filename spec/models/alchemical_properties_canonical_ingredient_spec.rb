# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlchemicalPropertiesCanonicalIngredient, type: :model do
  describe 'validations' do
    describe 'number of records per ingredient' do
      let(:ingredient) { create(:canonical_ingredient) }

      it 'cannot have more than 4 records corresponding to one ingredient' do
        4.times do |n|
          ingredient.alchemical_properties_canonical_ingredients.create!(
            alchemical_property: create(:alchemical_property),
            priority:            n + 1,
          )
        end

        new_association = build(:alchemical_properties_canonical_ingredient, canonical_ingredient: ingredient)

        new_association.validate
        expect(new_association.errors[:canonical_ingredient]).to include 'already has 4 alchemical properties'
      end
    end

    describe 'priority' do
      let(:ingredient) { create(:canonical_ingredient) }

      before do
        create(
          :alchemical_properties_canonical_ingredient,
          priority:             1,
          canonical_ingredient: ingredient,
        )
      end

      it 'must be unique per ingredient' do
        model = build(
                  :alchemical_properties_canonical_ingredient,
                  priority:             1,
                  canonical_ingredient: ingredient,
                )

        model.validate
        expect(model.errors[:priority]).to include 'must be unique per ingredient'
      end

      it "isn't required to be globally unique" do
        model = build(:alchemical_properties_canonical_ingredient, priority: 1)

        expect(model).to be_valid
      end
    end
  end
end
