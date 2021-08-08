# frozen_string_literal: true

class AddUnitWeightToShoppingListItems < ActiveRecord::Migration[6.1]
  def change
    add_column :shopping_list_items, :unit_weight, :decimal, precision: 5, scale: 1
  end
end
