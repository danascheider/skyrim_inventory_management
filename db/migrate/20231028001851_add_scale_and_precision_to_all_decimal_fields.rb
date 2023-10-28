# frozen_string_literal: true

class AddScaleAndPrecisionToAllDecimalFields < ActiveRecord::Migration[7.1]
  def change
    change_column :armors, :unit_weight, :decimal, scale: 2, precision: 5
    change_column :books, :unit_weight, :decimal, scale: 2, precision: 5
    change_column :canonical_misc_items, :unit_weight, :decimal, scale: 2, precision: 5
    change_column :canonical_potions, :unit_weight, :decimal, scale: 2, precision: 5
    change_column :clothing_items, :unit_weight, :decimal, scale: 2, precision: 5
    change_column :ingredients, :unit_weight, :decimal, scale: 2, precision: 5
    change_column :jewelry_items, :unit_weight, :decimal, scale: 2, precision: 5
  end
end
