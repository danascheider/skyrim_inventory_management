# frozen_string_literal: true

class CreateStaves < ActiveRecord::Migration[7.0]
  def change
    create_table :staves do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_staff, foreign_key: true
      t.string :name, null: false
      t.decimal :unit_weight, scale: 2, precision: 5
      t.string :magical_effects

      t.timestamps
    end
  end
end
