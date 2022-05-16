# frozen_string_literal: true

class CreatePowers < ActiveRecord::Migration[6.1]
  def change
    create_table :powers do |t|
      t.string :name, null: false, unique: true
      t.string :power_type, null: false
      t.string :source, null: false
      t.string :description, null: false

      t.index :name, unique: true

      t.timestamps
    end
  end
end
