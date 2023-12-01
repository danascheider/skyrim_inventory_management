# frozen_string_literal: true

class ShoppingListItem < ApplicationRecord
  self.table_name = 'wish_list_items'

  def self.list_class
    ShoppingList
  end

  def self.list_table_name
    'wish_lists'
  end

  include Listable
end
