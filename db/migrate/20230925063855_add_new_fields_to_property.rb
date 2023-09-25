# frozen_string_literal: true

class AddNewFieldsToProperty < ActiveRecord::Migration[7.0]
  def change
    change_table :properties do |t|
      t.column :has_enchanters_tower, :boolean
      t.column :has_alchemy_tower, :boolean
      t.column :has_library, :boolean
      t.column :has_bedrooms, :boolean
      t.column :has_storage_room, :boolean
      t.column :has_armory, :boolean
      t.column :has_greenhouse, :boolean
      t.column :has_trophy_room, :boolean
      t.column :has_kitchen, :boolean
      t.column :has_cellar, :boolean
      t.column :has_apiary, :boolean
      t.column :has_fish_hatchery, :boolean
      t.column :has_grain_mill, :boolean
    end
  end
end
