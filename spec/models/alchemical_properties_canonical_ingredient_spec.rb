# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlchemicalPropertiesCanonicalIngredient, type: :model do
  describe 'validations' do
    describe 'number of records per ingredient' do
      let(:ingredient) { create(:canonical_ingredient) }

      it 'cannot have more than 4 records corresponding to one ingredient' do
        4.times do
          ingredient.alchemical_properties << create(:alchemical_property)
        end

        new_association = build(:alchemical_properties_canonical_ingredient, canonical_ingredient: ingredient)

        new_association.validate
        expect(new_association.errors[:canonical_ingredient]).to include 'already has 4 alchemical properties'
      end
    end
  end
end
