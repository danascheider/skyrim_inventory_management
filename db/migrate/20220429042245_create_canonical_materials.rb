# frozen_string_literal: true

class CreateCanonicalMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_materials do |t|
      t.string :name, null: false
      t.string :item_code, null: false, unique: true
      t.boolean :building_material, default: false
      t.boolean :smithing_material, default: false
      t.decimal :unit_weight, precision: 5, scale: 2, null: false
      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
