# frozen_string_literal: true

class CreateCanonicalProperties < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_properties do |t|
      t.string :name, null: false, unique: true
      t.string :hold, null: false, unique: true
      t.string :city
      t.boolean :alchemy_lab_available, default: true
      t.boolean :arcane_enchanter_available, default: false
      t.boolean :forge_available, default: false
      t.index :name, unique: true
      t.index :hold, unique: true

      t.timestamps
    end
  end
end
