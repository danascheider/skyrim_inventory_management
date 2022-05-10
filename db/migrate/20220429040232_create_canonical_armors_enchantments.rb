# frozen_string_literal: true

class CreateCanonicalArmorsEnchantments < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_armors_enchantments do |t|
      t.references :armor, null: false, foreign_key: { to_table: 'canonical_armors' }
      t.references :enchantment, null: false, foreign_key: true

      t.decimal :strength, scale: 2, precision: 5

      t.timestamps
    end
  end
end
