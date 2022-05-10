# frozen_string_literal: true

class CreateCanonicalArmorsSmithingMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_armors_smithing_materials do |t|
      t.references :armor,
                   null:        false,
                   foreign_key: { to_table: 'canonical_armors' },
                   index:       { name: :index_canonical_armors_smithing_mats_on_canonical_armor_id }
      t.references :material,
                   null:        false,
                   foreign_key: { to_table: 'canonical_materials' },
                   index:       { name: :index_canonical_armors_smithing_mats_on_canonical_mat_id }
      t.integer    :quantity,
                   default: 1,
                   null:    false

      t.timestamps
    end
  end
end
