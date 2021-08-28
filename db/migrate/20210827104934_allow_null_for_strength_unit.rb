# frozen_string_literal: true

class AllowNullForStrengthUnit < ActiveRecord::Migration[6.1]
  def change
    change_column_null :enchantments, :strength_unit, true
  end
end
