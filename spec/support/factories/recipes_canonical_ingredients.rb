# frozen_string_literal: true

FactoryBot.define do
  factory :recipes_canonical_ingredient, class: Canonical::RecipesIngredient do
    association :recipe, factory: :canonical_recipe
    association :ingredient, factory: :canonical_ingredient
  end
end
