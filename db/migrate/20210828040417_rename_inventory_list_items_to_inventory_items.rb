# frozen_string_literal: true

class RenameInventoryListItemsToInventoryItems < ActiveRecord::Migration[6.1]
  def change
    rename_table :inventory_list_items, :inventory_items
  end
end
