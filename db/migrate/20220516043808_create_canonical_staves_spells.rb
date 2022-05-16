# frozen_string_literal: true

class CreateCanonicalStavesSpells < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_staves_spells do |t|
      t.references :spell, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: { to_table: 'canonical_staves' }
      t.integer :strength

      t.index %i[spell_id staff_id], unique: true

      t.timestamps
    end
  end
end
