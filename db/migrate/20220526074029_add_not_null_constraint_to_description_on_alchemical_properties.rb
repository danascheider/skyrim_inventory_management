# frozen_string_literal: true

class AddNotNullConstraintToDescriptionOnAlchemicalProperties < ActiveRecord::Migration[6.1]
  def change
    change_column_null :alchemical_properties, :description, false
  end
end
