# frozen_string_literal: true

class CreateInventoryLists < ActiveRecord::Migration[6.1]
  def change
    create_table :inventory_lists do |t|
      t.references :game, null: false, foreign_key: true
      t.references :aggregate_list, foreign_key: { to_table: 'inventory_lists' }
      t.string :title, null: false
      t.boolean :aggregate, null: false, default: false

      t.timestamps
    end

    add_index :inventory_lists, %i[title game_id]
  end
end
