# frozen_string_literal: true

class AddUniqueIndexToTitleOnShoppingLists < ActiveRecord::Migration[6.1]
  def change
    add_index :shopping_lists, %i[title game_id], unique: true
  end
end
