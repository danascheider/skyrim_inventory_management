# frozen_string_literal: true

class CreateShoppingLists < ActiveRecord::Migration[6.1]
  def change
    create_table :shopping_lists do |t|
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
