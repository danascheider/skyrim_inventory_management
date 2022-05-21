# frozen_string_literal: true

class CreateCanonicalBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_books do |t|
      t.string :title, null: false
      t.string :title_variants, array: true, default: []
      t.string :item_code, null: false, unique: true
      t.decimal :unit_weight, precision: 5, scale: 2, null: false
      t.string :book_type, null: false
      t.string :authors, array: true, default: []
      t.string :skill_name
      t.boolean :purchasable, null: false
      t.boolean :unique_item, null: false, default: false
      t.boolean :rare_item, null: false, default: false
      t.boolean :solstheim_only, null: false, default: false
      t.boolean :quest_item, null: false, default: false

      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
