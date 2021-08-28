# frozen_string_literal: true

class InventoryItem < ApplicationRecord
  def self.list_class
    InventoryList
  end

  def self.list_table_name
    'inventory_lists'
  end

  include Listable
end
