# frozen_string_literal: true

class AddCompositeIndexesToJoinTables < ActiveRecord::Migration[6.1]
  def change
    add_index :canonical_armors_enchantments,
              %i[armor_id enchantment_id],
              unique: true,
              name:   'index_can_armors_enchantments_on_armor_id_and_ench_id'
    add_index :canonical_armors_smithing_materials,
              %i[armor_id material_id],
              unique: true,
              name:   'index_can_armors_smithing_mats_on_armor_id_and_mat_id'
    add_index :canonical_armors_tempering_materials,
              %i[armor_id material_id],
              unique: true,
              name:   'index_can_armors_tempering_mats_on_armor_id_and_mat_id'
    add_index :canonical_clothing_items_enchantments,
              %i[clothing_item_id enchantment_id],
              unique: true,
              name:   'index_can_clthng_enchantments_on_clthng_id_and_ench_id'
    add_index :canonical_jewelry_items_materials,
              %i[jewelry_item_id material_id],
              unique: true,
              name:   'index_can_jlry_mats_on_jlry_id_and_mat_id'
    add_index :canonical_jewelry_items_enchantments,
              %i[jewelry_item_id enchantment_id],
              unique: true,
              name:   'index_can_jlry_enchs_on_jlry_id_and_ench_id'
  end
end
