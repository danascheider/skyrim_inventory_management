# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :email, null: false
      t.string :name

      t.timestamps
    end

    add_index :users, :uid
  end
end
