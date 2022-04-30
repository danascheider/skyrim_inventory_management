# frozen_string_literal: true

class CreateCanonicalJewelryItemsEnchantments < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_jewelry_items_enchantments do |t|
      t.references :canonical_jewelry_item,
                   null:        false,
                   foreign_key: true,
                   index:       { name: :index_canonical_jewelry_items_enchantments_on_jewelry_item_id }
      t.references :enchantment, null: false, foreign_key: true

      t.integer :strength

      t.timestamps
    end
  end
end
