# frozen_string_literal: true

class AddBodySlotToCanonicalClothingItems < ActiveRecord::Migration[6.1]
  def change
    add_column :canonical_clothing_items, :body_slot, :string, null: false
  end
end
