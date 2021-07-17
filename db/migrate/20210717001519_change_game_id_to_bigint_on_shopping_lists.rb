# frozen_string_literal: true

class ChangeGameIdToBigintOnShoppingLists < ActiveRecord::Migration[6.1]
  def change
    remove_column :shopping_lists, :game_id, :integer, null: false
    add_reference :shopping_lists, :game, null: false, foreign_key: true
  end
end
