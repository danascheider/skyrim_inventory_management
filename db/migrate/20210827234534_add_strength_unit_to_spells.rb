# frozen_string_literal: true

class AddStrengthUnitToSpells < ActiveRecord::Migration[6.1]
  def change
    add_column :spells, :strength_unit, :string
  end
end
