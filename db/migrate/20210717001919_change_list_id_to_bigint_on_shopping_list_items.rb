# frozen_string_literal: true

class ChangeListIdToBigintOnShoppingListItems < ActiveRecord::Migration[6.1]
  def change
    remove_column :shopping_list_items, :list_id, :integer, null: false
    add_reference :shopping_list_items, :list, null: false, foreign_key: { to_table: :shopping_lists }
  end
end
