# frozen_string_literal: true

class CreateCanonicalArmorsSmithingMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_armors_smithing_materials do |t|
      t.references :canonical_armor,
                   null:        false,
                   foreign_key: true,
                   index:       { name: :index_canonical_armors_smithing_mats_on_canonical_armor_id }
      t.references :canonical_materials,
                   null:        false,
                   foreign_key: true,
                   index:       { name: :index_canonical_armors_smithing_mats_on_canonical_mat_id }

      t.timestamps
    end
  end
end
