# frozen_string_literal: true

class CreateCanonicalClothingItemsEnchantments < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_clothing_items_enchantments do |t|
      t.references :clothing_item,
                   null:        false,
                   foreign_key: { to_table: 'canonical_clothing_items' },
                   index:       { name: :index_canonical_clothing_enchantments_on_canonical_clothing_id }
      t.references :enchantment, null: false, foreign_key: true

      t.decimal :strength, precision: 5, scale: 2

      t.timestamps
    end
  end
end
