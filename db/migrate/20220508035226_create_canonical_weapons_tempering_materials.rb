# frozen_string_literal: true

class CreateCanonicalWeaponsTemperingMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_weapons_tempering_materials do |t|
      t.references :weapon,
                   null:        false,
                   foreign_key: { to_table: 'canonical_weapons' },
                   index:       { name: 'index_can_weapons_temp_mats_on_mat_id' }
      t.references :material,
                   null:        false,
                   foreign_key: { to_table: 'canonical_materials' },
                   index:       { name: 'index_can_weapons_temp_mats_on_can_weap_id' }
      t.integer :quantity, null: false

      t.index %i[weapon_id material_id], unique: true, name: 'index_can_weapons_temp_mats_on_weap_and_mat_ids'

      t.timestamps
    end
  end
end
