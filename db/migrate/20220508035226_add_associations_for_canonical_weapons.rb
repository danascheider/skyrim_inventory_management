# frozen_string_literal: true

class AddAssociationsForCanonicalWeapons < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_weapons_enchantments do |t|
      t.references :weapon,
                   null:        false,
                   foreign_key: { to_table: 'canonical_weapons' },
                   index:       { name: 'index_can_weapons_enchantments_on_ench_id' }
      t.references :enchantment,
                   null:        false,
                   foreign_key: true,
                   index:       { name: 'index_can_weapons_enchantments_on_can_weapon_id' }
      t.decimal :strength, precision: 5, scale: 2

      t.index %i[weapon_id enchantment_id], unique: true, name: 'index_can_weapons_enchantments_on_weap_and_ench_ids'

      t.timestamps
    end

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

    create_table :canonical_weapons_smithing_materials do |t|
      t.references :weapon,
                   null:        false,
                   foreign_key: { to_table: 'canonical_weapons' },
                   index:       { name: 'index_can_weapons_sm_mats_on_mat_id' }
      t.references :material,
                   null:        false,
                   foreign_key: { to_table: 'canonical_materials' },
                   index:       { name: 'index_can_weapons_sm_mats_on_can_weap_id' }
      t.integer :quantity, null: false

      t.index %i[weapon_id material_id], unique: true, name: 'index_can_weapons_sm_mats_on_weap_and_mat_ids'

      t.timestamps
    end
  end
end
