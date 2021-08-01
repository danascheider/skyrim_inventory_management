# frozen_string_literal: true

class AddTitleToShoppingLists < ActiveRecord::Migration[6.1]
  def change
    add_column :shopping_lists, :title, :string, null: false
    add_index :shopping_lists, %i[user_id title], unique: true
  end
end
