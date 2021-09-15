# frozen_string_literal: true

class AddPropertyIdToShoppingLists < ActiveRecord::Migration[6.1]
  def change
    add_reference :shopping_lists, :property, foreign_key: true
  end
end
