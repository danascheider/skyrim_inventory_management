# frozen_string_literal: true

class CreateClothingItems < ActiveRecord::Migration[7.0]
  def change
    create_table :clothing_items do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_clothing_item, foreign_key: true

      t.string :name, null: false
      t.decimal :unit_weight
      t.string :magical_effects

      t.timestamps
    end
  end
end
