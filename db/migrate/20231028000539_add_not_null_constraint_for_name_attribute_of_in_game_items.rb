# frozen_string_literal: true

class AddNotNullConstraintForNameAttributeOfInGameItems < ActiveRecord::Migration[7.1]
  def change
    change_column_null :armors, :name, false
    change_column_null :books, :title, false
    change_column_null :clothing_items, :name, false
    change_column_null :ingredients, :name, false
    change_column_null :jewelry_items, :name, false
    change_column_null :misc_items, :name, false
    change_column_null :potions, :name, false
    change_column_null :properties, :name, false
    change_column_null :staves, :name, false
    change_column_null :weapons, :name, false
  end
end
