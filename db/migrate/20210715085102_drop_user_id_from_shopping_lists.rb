# frozen_string_literal: true

class DropUserIdFromShoppingLists < ActiveRecord::Migration[6.1]
  def change
    remove_column :shopping_lists, :user_id, null: false
  end
end
