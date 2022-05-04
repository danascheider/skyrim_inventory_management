# frozen_string_literal: true

class CreateCanonicalIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_ingredients do |t|
      t.string :name, null: false
      t.string :item_code, null: false, unique: true

      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
