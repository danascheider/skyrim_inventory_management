# frozen_string_literal: true

class ChangeMasterLanguageToAggregateOnShoppingLists < ActiveRecord::Migration[6.1]
  def change
    rename_column :shopping_lists, :master, :aggregate
    rename_column :shopping_lists, :master_list_id, :aggregate_list_id
  end
end
