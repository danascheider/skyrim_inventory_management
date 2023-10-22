# frozen_string_literal: true

class MakeRecipesCanonicalIngredientsPolymorphic < ActiveRecord::Migration[7.1]
  def up
    remove_foreign_key :recipes_canonical_ingredients, column: :recipe_id
    add_column :recipes_canonical_ingredients, :recipe_type, :string

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
