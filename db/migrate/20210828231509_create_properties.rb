# frozen_string_literal: true

class CreateProperties < ActiveRecord::Migration[6.1]
  def change
    create_table :properties do |t|
      t.references :game, null: false, foreign_key: true
      t.references :canonical_property, null: false, foreign_key: true
      t.string :name, null: false
      t.string :hold, null: false
      t.string :city
      t.boolean :has_alchemy_lab, default: false
      t.boolean :has_arcane_enchanter, default: false
      t.boolean :has_forge, default: false

      t.index %i[game_id name], unique: true
      t.index %i[game_id hold], unique: true
      t.index %i[game_id city], unique: true
      t.index %i[game_id canonical_property_id], unique: true

      t.timestamps
    end
  end
end
