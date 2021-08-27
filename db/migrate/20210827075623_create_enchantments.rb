# frozen_string_literal: true

class CreateEnchantments < ActiveRecord::Migration[6.1]
  def change
    create_table :enchantments do |t|
      t.string :name, null: false, unique: true
      t.string :enchantable_items, array: true, default: []
      t.string :strength_unit, null: false

      t.timestamps
    end

    add_index :enchantments, :name, unique: true
  end
end
