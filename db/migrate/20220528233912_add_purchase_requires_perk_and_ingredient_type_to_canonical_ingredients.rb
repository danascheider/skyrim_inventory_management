# frozen_string_literal: true

class AddPurchaseRequiresPerkAndIngredientTypeToCanonicalIngredients < ActiveRecord::Migration[6.1]
  def change
    add_column :canonical_ingredients, :ingredient_type, :string
    add_column :canonical_ingredients, :purchase_requires_perk, :boolean
  end
end
