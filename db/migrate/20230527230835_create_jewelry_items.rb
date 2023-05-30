# frozen_string_literal: true

class CreateJewelryItems < ActiveRecord::Migration[7.0]
  def change
    create_table :jewelry_items do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_jewelry_item, foreign_key: true
      t.string :name
      t.decimal :unit_weight
      t.string :jewelry_type
      t.string :magical_effects

      t.timestamps
    end
  end
end
