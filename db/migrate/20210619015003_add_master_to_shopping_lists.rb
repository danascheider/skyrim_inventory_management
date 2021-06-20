# frozen_string_literal: true

class AddMasterToShoppingLists < ActiveRecord::Migration[6.1]
  def change
    add_column :shopping_lists, :master, :boolean, default: false
  end
end
