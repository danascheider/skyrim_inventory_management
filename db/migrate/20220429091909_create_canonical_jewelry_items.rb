# frozen_string_literal: true

class CreateCanonicalJewelryItems < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_jewelry_items do |t|
      t.string :name, null: false, unique: true
      t.string :jewelry_type, null: false
      t.decimal :unit_weight, scale: 1, precision: 5
      t.boolean :quest_item

      t.index :name, unique: true

      t.timestamps
    end
  end
end
