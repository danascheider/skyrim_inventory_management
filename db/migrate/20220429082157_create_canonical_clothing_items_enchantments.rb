# frozen_string_literal: true

class CreateCanonicalClothingItemsEnchantments < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_clothing_items_enchantments do |t|
      t.references :canonical_clothing_item,
                   null:        false,
                   foreign_key: true,
                   index:       { name: :index_canonical_clothing_enchantments_on_canonical_clothing_id }
      t.references :enchantment, null: false, foreign_key: true

      t.integer :strength

      t.timestamps
    end
  end
end
