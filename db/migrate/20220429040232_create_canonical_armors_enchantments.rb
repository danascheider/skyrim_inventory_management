# frozen_string_literal: true

class CreateCanonicalArmorsEnchantments < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_armors_enchantments do |t|
      t.references :canonical_armor, null: false, foreign_key: true
      t.references :enchantment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
