# frozen_string_literal: true

class CreateAlchemicalProperties < ActiveRecord::Migration[6.1]
  def change
    create_table :alchemical_properties do |t|
      t.string :name, null: false, unique: true
      t.string :strength_unit
      t.boolean :effects_cumulative, default: false

      t.timestamps
    end
  end
end
