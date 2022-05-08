# frozen_string_literal: true

class CreateCanonicalWeapons < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_weapons do |t|
      t.string :name, null: false
      t.string :item_code, null: false, unique: true
      t.string :category, null: false
      t.string :weapon_type, null: false
      t.string :magical_effects
      t.string :smithing_perks, array: true, default: []
      t.integer :base_damage, null: false
      t.decimal :unit_weight, null: false, precision: 5, scale: 2
      t.boolean :levelled, default: false
      t.boolean :enchantable, default: true
      t.boolean :quest_item, default: false
      t.boolean :unique_item, default: false

      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
