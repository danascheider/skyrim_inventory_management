# frozen_string_literal: true

class CreateCanonicalMiscItems < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_misc_items do |t|
      t.string :name, null: false
      t.string :item_code, null: false, unique: true
      t.decimal :unit_weight, null: false
      t.string :item_types, array: true, null: false, default: []
      t.string :description
      t.boolean :purchasable, null: false
      t.boolean :unique_item, null: false
      t.boolean :rare_item, null: false
      t.boolean :quest_item, null: false, default: false

      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
