# frozen_string_literal: true

class CreateCanonicalStaves < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_staves do |t|
      t.string :name, null: false
      t.string :item_code, null: false, unique: true
      t.decimal :unit_weight, null: false, precision: 5, scale: 2
      t.integer :base_damage, null: false
      t.string :magical_effects
      t.string :school
      t.string :dragon_priest
      t.boolean :daedric, null: false, default: false
      t.boolean :unique_item, null: false, default: false
      t.boolean :quest_item, null: false, default: false
      t.boolean :leveled, null: false, default: false

      t.index :item_code, unique: true

      t.timestamps
    end
  end
end
