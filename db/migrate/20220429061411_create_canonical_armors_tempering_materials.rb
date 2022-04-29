# frozen_string_literal: true

class CreateCanonicalArmorsTemperingMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_armors_tempering_materials do |t|
      t.references :canonical_armor,
                   null:        false,
                   foreign_key: true,
                   index:       { name: :index_canonical_armors_tempering_mats_on_canonical_armor_id }
      t.references :canonical_material,
                   null:        false,
                   foreign_key: true,
                   index:       { name: :index_canonical_armors_tempering_mats_on_canonical_material_id }
      t.integer    :count,
                   default: 1,
                   null:    false

      t.timestamps
    end
  end
end
