# frozen_string_literal: true

class ChangeAggregateListIdToBigintOnShoppingLists < ActiveRecord::Migration[6.1]
  def change
    remove_column :shopping_lists, :aggregate_list_id, :integer
    add_reference :shopping_lists, :aggregate_list, foreign_key: { to_table: :shopping_lists }
  end
end
