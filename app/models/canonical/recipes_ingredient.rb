# frozen_string_literal: true

module Canonical
  class RecipesIngredient < ApplicationRecord
    self.table_name = 'canonical_recipes_ingredients'

    belongs_to :recipe, class_name: 'Canonical::Book'
    belongs_to :ingredient, class_name: 'Canonical::Ingredient'

    validate :verify_recipe_is_recipe

    private

    def verify_recipe_is_recipe
      errors.add(:recipe, 'must be a recipe') unless recipe.book_type == 'recipe'
    end
  end
end
