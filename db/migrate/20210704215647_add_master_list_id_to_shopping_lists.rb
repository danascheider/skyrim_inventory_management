# frozen_string_literal: true

class AddMasterListIdToShoppingLists < ActiveRecord::Migration[6.1]
  def change
    add_column :shopping_lists, :master_list_id, :integer
  end
end
