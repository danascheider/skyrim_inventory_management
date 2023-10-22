# frozen_string_literal: true

class MakeCanonicalRecipesIngredientsNonCanonical < ActiveRecord::Migration[7.1]
  def change
    rename_table :canonical_recipes_ingredients, :recipes_canonical_ingredients
  end
end
