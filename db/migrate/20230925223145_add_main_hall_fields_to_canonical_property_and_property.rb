# frozen_string_literal: true

class AddMainHallFieldsToCanonicalPropertyAndProperty < ActiveRecord::Migration[7.0]
  def change
    add_column :canonical_properties, :main_hall_available, :boolean
    add_column :properties, :has_main_hall, :boolean
  end
end
