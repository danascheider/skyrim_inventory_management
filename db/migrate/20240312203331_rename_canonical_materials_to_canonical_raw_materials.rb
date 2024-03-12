# frozen_string_literal: true

class RenameCanonicalMaterialsToCanonicalRawMaterials < ActiveRecord::Migration[7.1]
  def change
    rename_table :canonical_materials, :canonical_raw_materials
  end
end
