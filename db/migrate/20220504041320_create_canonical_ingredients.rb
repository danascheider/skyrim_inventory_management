# frozen_string_literal: true

class CreateCanonicalIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_ingredients do |t|
      t.string :name, null: false
      t.string :item_code, null: false, unique: true
      t.decimal :unit_weight, null: false, scale: 2, precision: 5
      t.boolean :purchasable
      t.boolean :unique_item, default: false
      t.boolean :rare_item
      t.boolean :quest_item, default: false

      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
