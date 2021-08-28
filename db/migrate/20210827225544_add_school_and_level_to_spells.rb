# frozen_string_literal: true

class AddSchoolAndLevelToSpells < ActiveRecord::Migration[6.1]
  def change
    add_column :spells, :school, :string, null: false
    add_column :spells, :level, :string, null: false
  end
end
