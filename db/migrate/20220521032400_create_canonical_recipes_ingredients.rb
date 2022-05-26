# frozen_string_literal: true

class CreateCanonicalRecipesIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_recipes_ingredients do |t|
      t.references :recipe, null: false, foreign_key: { to_table: 'canonical_books' }
      t.references :ingredient, null: false, foreign_key: { to_table: 'canonical_ingredients' }

      t.index %i[recipe_id ingredient_id], unique: true, name: 'index_can_books_ingredients_on_recipe_and_ingredient'

      t.timestamps
    end
  end
end
