# frozen_string_literal: true

class CreateArmors < ActiveRecord::Migration[7.0]
  def change
    create_table :armors do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_armor, foreign_key: true

      t.string :name, null: false
      t.decimal :unit_weight
      t.string :magical_effects
      t.string :weight

      t.timestamps
    end
  end
end
