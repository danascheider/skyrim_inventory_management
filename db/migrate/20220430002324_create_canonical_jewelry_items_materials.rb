# frozen_string_literal: true

class CreateCanonicalJewelryItemsMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_jewelry_items_materials do |t|
      t.references :jewelry_item,
                   null:        false,
                   foreign_key: { to_table: 'canonical_jewelry_items' },
                   index:       { name: :index_canonical_jewelry_items_materials_on_jewelry_id }
      t.references :material,
                   null:        false,
                   foreign_key: { to_table: 'canonical_materials' },
                   index:       { name: :index_canonical_jewelry_items_materials_on_material_id }
      t.integer    :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
