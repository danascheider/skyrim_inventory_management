# frozen_string_literal: true

class AddNewFieldsToCanonicalProperty < ActiveRecord::Migration[7.0]
  def change
    change_table :canonical_properties do |t|
      t.column :enchanters_tower_available, :boolean, default: false
      t.column :alchemy_tower_available, :boolean, default: false
      t.column :library_available, :boolean, default: false
      t.column :bedrooms_available, :boolean, default: false
      t.column :storage_room_available, :boolean, default: false
      t.column :armory_available, :boolean, default: false
      t.column :greenhouse_available, :boolean, default: false
      t.column :trophy_room_available, :boolean, default: false
      t.column :kitchen_available, :boolean, default: false
      t.column :apiary_available, :boolean, default: false
      t.column :grain_mill_available, :boolean, default: false
      t.column :fish_hatchery_available, :boolean, default: false
    end
  end
end
