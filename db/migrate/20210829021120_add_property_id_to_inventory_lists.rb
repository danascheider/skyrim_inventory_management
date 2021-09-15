# frozen_string_literal: true

class AddPropertyIdToInventoryLists < ActiveRecord::Migration[6.1]
  def change
    add_reference :inventory_lists, :property, foreign_key: true
  end
end
