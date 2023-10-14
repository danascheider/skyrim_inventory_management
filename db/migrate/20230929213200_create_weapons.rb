# frozen_string_literal: true

class CreateWeapons < ActiveRecord::Migration[7.0]
  def change
    create_table :weapons do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_weapon, foreign_key: true
      t.string :name, null: false
      t.string :category
      t.string :weapon_type
      t.string :magical_effects
      t.decimal :unit_weight, scale: 2, precision: 5

      t.timestamps
    end
  end
end
