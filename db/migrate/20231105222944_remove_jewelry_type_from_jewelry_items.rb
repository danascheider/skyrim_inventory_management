# frozen_string_literal: true

class RemoveJewelryTypeFromJewelryItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :jewelry_items, :jewelry_type, :string
  end
end
