# frozen_string_literal: true

class CreateCanonicalClothingItems < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_clothing_items do |t|
      t.string :name, null: false
      t.string :item_code, null: false, unique: true
      t.string :body_slot, null: false
      t.string :magical_effects
      t.decimal :unit_weight, precision: 5, scale: 2, null: false
      t.boolean :purchasable
      t.boolean :unique_item, default: false
      t.boolean :rare_item
      t.boolean :quest_item, default: false
      t.boolean :enchantable, default: true

      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
