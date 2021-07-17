# frozen_string_literal: true

class AddUniqueIndexToDescriptionOnShoppingListItem < ActiveRecord::Migration[6.1]
  def change
    add_index :shopping_list_items, %i[description list_id], unique: true
  end
end
