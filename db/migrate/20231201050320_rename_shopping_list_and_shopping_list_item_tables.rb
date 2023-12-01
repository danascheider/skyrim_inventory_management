# frozen_string_literal: true

class RenameShoppingListAndShoppingListItemTables < ActiveRecord::Migration[7.1]
  def change
    # Remove the foreign key constraint because it will point to the wrong table name
    remove_foreign_key :shopping_list_items, :shopping_lists

    rename_table :shopping_lists, :wish_lists
    rename_table :shopping_list_items, :wish_list_items

    # Update foreign key reference
    add_foreign_key :wish_list_items, :wish_lists, column: :list_id
  end
end
