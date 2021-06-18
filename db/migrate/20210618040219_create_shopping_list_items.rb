# frozen_string_literal: true

class CreateShoppingListItems < ActiveRecord::Migration[6.1]
  def change
    create_table :shopping_list_items do |t|
      t.integer :shopping_list_id, null: false
      t.string :description, null: false
      t.string :notes
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end
end
