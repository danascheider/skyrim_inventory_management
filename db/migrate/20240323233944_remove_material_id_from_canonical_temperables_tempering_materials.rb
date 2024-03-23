# frozen_string_literal: true

class RemoveMaterialIdFromCanonicalTemperablesTemperingMaterials < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :canonical_temperables_tempering_materials, :canonical_raw_materials
    remove_column :canonical_temperables_tempering_materials, :material_id
  end
end
