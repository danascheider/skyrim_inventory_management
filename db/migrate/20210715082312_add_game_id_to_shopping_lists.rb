# frozen_string_literal: true

class AddGameIdToShoppingLists < ActiveRecord::Migration[6.1]
  def change
    add_reference :shopping_lists, :game, foreign_key: true, null: false
  end
end
