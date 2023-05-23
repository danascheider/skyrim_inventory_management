# frozen_string_literal: true

class CreateIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :ingredients do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_ingredient, foreign_key: true
      t.string :name
      t.decimal :unit_weight, scale: 2, precision: 5

      t.timestamps
    end
  end
end
