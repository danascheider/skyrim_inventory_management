# frozen_string_literal: true

class CreateCanonicalClothingItems < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_clothing_items do |t|
      t.string :name, null: false, unique: true
      t.string :magical_effects
      t.decimal :unit_weight, precision: 5, scale: 1
      t.boolean :quest_item, default: false
      t.boolean :unique_item, default: false
      t.boolean :enchantable, default: true

      t.index :name, unique: true

      t.timestamps
    end
  end
end
