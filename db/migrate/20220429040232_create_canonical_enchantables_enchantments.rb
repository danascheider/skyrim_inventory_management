# frozen_string_literal: true

class CreateCanonicalEnchantablesEnchantments < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_enchantables_enchantments do |t|
      t.references :enchantment, null: false, foreign_key: true
      t.bigint     :enchantable_id, null: false
      t.string     :enchantable_type, null: false
      t.decimal    :strength, scale: 2, precision: 5

      t.index %i[enchantment_id enchantable_id enchantable_type], unique: true, name: 'index_enchantables_enchantments_on_enchmnt_id_enchble_id_type'

      t.timestamps
    end
  end
end
