# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_book, foreign_key: true
      t.string :title, null: false
      t.string :title_variants, array: true, default: []
      t.string :authors, array: true, default: []
      t.decimal :unit_weight
      t.string :skill_name

      t.timestamps
    end
  end
end
