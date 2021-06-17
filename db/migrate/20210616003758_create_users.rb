# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :uid, null: false, unique: true
      t.string :email, null: false, unique: true
      t.string :name

      t.timestamps
    end

    add_index :users, :uid, unique: true
    add_index :users, :email, unique: true
  end
end
