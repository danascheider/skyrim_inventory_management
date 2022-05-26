# frozen_string_literal: true

class CreateCanonicalPotions < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_potions do |t|
      t.string :name, null: false
      t.string :item_code, null: false, unique: true
      t.decimal :unit_weight, null: false
      t.string :potion_type, null: false
      t.string :magical_effects
      t.boolean :purchasable, null: false, default: true
      t.boolean :unique_item, null: false, default: false
      t.boolean :rare_item, null: false, default: false
      t.boolean :quest_item, null: false, default: false

      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
