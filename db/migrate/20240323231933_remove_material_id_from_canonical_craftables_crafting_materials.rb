# frozen_string_literal: true

class RemoveMaterialIdFromCanonicalCraftablesCraftingMaterials < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :canonical_craftables_crafting_materials, :canonical_raw_materials
    remove_column :canonical_craftables_crafting_materials, :material_id
  end
end
