# frozen_string_literal: true

class CreateCanonicalJewelryItemsEnchantments < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_jewelry_items_enchantments do |t|
      t.references :jewelry_item,
                   null:        false,
                   foreign_key: { to_table: 'canonical_jewelry_items' },
                   index:       { name: :index_canonical_jewelry_items_enchantments_on_jewelry_item_id }
      t.references :enchantment, null: false, foreign_key: true

      t.decimal :strength, precision: 5, scale: 2

      t.timestamps
    end
  end
end
