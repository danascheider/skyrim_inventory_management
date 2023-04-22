# frozen_string_literal: true

class ShoppingListItem < ApplicationRecord
  include Listable
  def self.list_class
    ShoppingList
  end

  def self.list_table_name
    'shopping_lists'
  end
end
