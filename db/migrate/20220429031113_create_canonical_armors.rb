# frozen_string_literal: true

class CreateCanonicalArmors < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_armors do |t|
      t.string :name, null: false
      t.string :weight, null: false
      t.string :body_slot, null: false
      t.boolean :dragon_priest_mask, default: false

      t.timestamps
    end
  end
end
