# frozen_string_literal: true

class CreateProperties < ActiveRecord::Migration[6.1]
  def change
    create_table :properties do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.boolean :buildable, default: false

      t.timestamps
    end

    add_foreign_key :properties, :users
  end
end
