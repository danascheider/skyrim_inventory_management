# frozen_string_literal: true

class AddNotNullConstraintToAddOnField < ActiveRecord::Migration[7.2]
  def change
    change_column_null :canonical_armors, :add_on, false
    change_column_null :canonical_potions, :add_on, false
    change_column_null :canonical_properties, :add_on, false
    change_column_null :canonical_books, :add_on, false
    change_column_null :canonical_clothing_items, :add_on, false
    change_column_null :canonical_ingredients, :add_on, false
    change_column_null :canonical_jewelry_items, :add_on, false
    change_column_null :canonical_misc_items, :add_on, false
    change_column_null :canonical_raw_materials, :add_on, false
    change_column_null :canonical_staves, :add_on, false
    change_column_null :canonical_weapons, :add_on, false
    change_column_null :enchantments, :add_on, false
    change_column_null :spells, :add_on, false
    change_column_null :alchemical_properties, :add_on, false
    change_column_null :powers, :add_on, false
  end
end