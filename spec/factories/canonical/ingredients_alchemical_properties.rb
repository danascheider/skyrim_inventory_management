# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_ingredients_alchemical_property, class: Canonical::IngredientsAlchemicalProperty do
    alchemical_property
    canonical_ingredient
    priority { 2 }
  end
end
