# frozen_string_literal: true

class CreateCanonicalMaterials2 < ActiveRecord::Migration[7.1]
  def change
    create_table :canonical_materials do |t|
      t.references :source_material, polymorphic: true, null: false
      t.references :joinable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
