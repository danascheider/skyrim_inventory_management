# frozen_string_literal: true

class MakeRecipesCanonicalIngredientsPolymorphic < ActiveRecord::Migration[7.1]
  def up
    remove_foreign_key :recipes_canonical_ingredients, column: :recipe_id
    add_column :recipes_canonical_ingredients, :recipe_type, :string
    remove_index :recipes_canonical_ingredients,
                 columns: %i[recipe_id ingredient_id],
                 unique: true,
                 name: 'index_can_books_ingredients_on_recipe_and_ingredient'
    add_index :recipes_canonical_ingredients,
              %i[recipe_id recipe_type ingredient_id],
              unique: true,
              name: 'index_recipes_can_ingredients_on_recipe_and_ingredient'

    # rubocop:disable Rails/SkipsModelValidations
    RecipesCanonicalIngredient.update_all(recipe_type: 'Canonical::Book')
    # rubocop:enable Rails/SkipsModelValidations

    change_column_null :recipes_canonical_ingredients, :recipe_type, false
  end

  def down
    add_foreign_key :recipes_canonical_ingredients,
                    :canonical_books,
                    column: :recipe_id
    remove_column :recipes_canonical_ingredients, :recipe_type
  end
end
