# frozen_string_literal: true

class AddCompositeIndexesToJoinTables < ActiveRecord::Migration[6.1]
  def change
    add_index :canonical_armors_enchantments,
              %i[canonical_armor_id enchantment_id],
              unique: true,
              name:   'index_can_armors_enchantments_on_can_armor_id_and_ench_id'
    add_index :canonical_armors_smithing_materials,
              %i[canonical_armor_id canonical_material_id],
              unique: true,
              name:   'index_can_armors_smithing_mats_on_can_armor_id_and_mat_id'
    add_index :canonical_armors_tempering_materials,
              %i[canonical_armor_id canonical_material_id],
              unique: true,
              name:   'index_can_armors_tempering_mats_on_can_armor_id_and_mat_id'
    add_index :canonical_clothing_items_enchantments,
              %i[canonical_clothing_item_id enchantment_id],
              unique: true,
              name:   'index_can_clthng_enchantments_on_can_clthng_id_and_ench_id'
    add_index :canonical_jewelry_items_canonical_materials,
              %i[canonical_jewelry_item_id canonical_material_id],
              unique: true,
              name:   'index_can_jlry_can_mats_on_jlry_id_and_mat_id'
    add_index :canonical_jewelry_items_enchantments,
              %i[canonical_jewelry_item_id enchantment_id],
              unique: true,
              name:   'index_can_jlry_enchs_on_jlry_id_and_ench_id'
  end
end
