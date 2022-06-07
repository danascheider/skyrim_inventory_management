# frozen_string_literal: true

class AddNotNullConstraintToBooleanFields < ActiveRecord::Migration[6.1]
  def change
    change_column_null :canonical_armors, :purchasable, false
    change_column_null :canonical_armors, :unique_item, false
    change_column_null :canonical_armors, :rare_item, false
    change_column_null :canonical_armors, :quest_item, false

    change_column_null :canonical_clothing_items, :purchasable, false
    change_column_null :canonical_clothing_items, :unique_item, false
    change_column_null :canonical_clothing_items, :rare_item, false
    change_column_null :canonical_clothing_items, :quest_item, false
    change_column_null :canonical_clothing_items, :enchantable, false

    change_column_null :canonical_ingredients, :purchasable, false
    change_column_null :canonical_ingredients, :unique_item, false
    change_column_null :canonical_ingredients, :rare_item, false
    change_column_null :canonical_ingredients, :quest_item, false

    change_column_null :canonical_jewelry_items, :purchasable, false
    change_column_null :canonical_jewelry_items, :unique_item, false
    change_column_null :canonical_jewelry_items, :rare_item, false
    change_column_null :canonical_jewelry_items, :quest_item, false
    change_column_null :canonical_jewelry_items, :enchantable, false

    change_column_null :canonical_staves, :purchasable, false
    change_column_null :canonical_staves, :rare_item, false

    change_column_null :canonical_weapons, :purchasable, false
    change_column_null :canonical_weapons, :unique_item, false
    change_column_null :canonical_weapons, :rare_item, false
    change_column_null :canonical_weapons, :quest_item, false
  end
end
