# frozen_string_literal: true

class AddSchoolToSpells < ActiveRecord::Migration[6.1]
  def change
    add_column :spells, :school, :string, null: false
  end
end
