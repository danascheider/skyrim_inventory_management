# frozen_string_literal: true

class CreateSpells < ActiveRecord::Migration[6.1]
  def change
    create_table :spells do |t|
      t.string :name, null: false, unique: true
      t.string :description, null: false
      t.integer :strength
      t.integer :base_duration
      t.boolean :effects_cumulative, default: false

      t.timestamps
    end

    add_index :spells, :name, unique: true
  end
end
