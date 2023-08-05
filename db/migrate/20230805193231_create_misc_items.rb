# frozen_string_literal: true

class CreateMiscItems < ActiveRecord::Migration[7.0]
  def change
    create_table :misc_items do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_misc_item, foreign_key: true

      t.string :name, null: false
      t.decimal :unit_weight, scale: 2, precision: 5

      t.timestamps
    end
  end
end
