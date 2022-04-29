# frozen_string_literal: true

class CreateCanonicalArmors < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_armors do |t|
      t.string :name, null: false
      t.string :weight, null: false
      t.string :body_slot, null: false
      t.string :magical_effects
      t.decimal :unit_weight, precision: 5, scale: 1
      t.boolean :dragon_priest_mask, default: false
      t.boolean :quest_item, default: false
      t.boolean :unique_item, default: false
      t.boolean :enchantable, default: true

      t.timestamps
    end
  end
end
