# frozen_string_literal: true

class CreateInventoryListItems < ActiveRecord::Migration[6.1]
  def change
    create_table :inventory_list_items do |t|
      t.references :list, null: false, foreign_key: { to_table: 'inventory_lists' }
      t.string :description, null: false
      t.string :notes
      t.decimal :weight, precision: 5, scale: 1

      t.timestamps
    end

    add_index :inventory_list_items, %i[description list_id], unique: true
  end
end
