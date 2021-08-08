# frozen_string_literal: true

class ShoppingListItem < ApplicationRecord
  def self.list_class
    ShoppingList
  end

  def self.list_table_name
    'shopping_lists'
  end

  include Listable
end
