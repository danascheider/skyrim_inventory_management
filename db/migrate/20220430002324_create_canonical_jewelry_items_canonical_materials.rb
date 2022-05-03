# frozen_string_literal: true

class CreateCanonicalJewelryItemsCanonicalMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_jewelry_items_canonical_materials do |t|
      t.references :canonical_jewelry_item,
                   null:        false,
                   foreign_key: true,
                   index:       { name: :index_canonical_jewelry_items_materials_on_jewelry_id }
      t.references :canonical_material,
                   null:        false,
                   foreign_key: true,
                   index:       { name: :index_canonical_jewelry_items_materials_on_material_id }
      t.integer    :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
