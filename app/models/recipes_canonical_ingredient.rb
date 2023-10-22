# frozen_string_literal: true

class RecipesCanonicalIngredient < ApplicationRecord
  belongs_to :recipe, polymorphic: true
  belongs_to :ingredient, class_name: 'Canonical::Ingredient'

  validate :verify_recipe_is_recipe

  private

  def verify_recipe_is_recipe
    errors.add(:recipe, 'must be a recipe') unless recipe.recipe?
  end
end
