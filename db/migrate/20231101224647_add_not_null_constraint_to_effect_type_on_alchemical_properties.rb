# frozen_string_literal: true

class AddNotNullConstraintToEffectTypeOnAlchemicalProperties < ActiveRecord::Migration[7.1]
  def change
    change_column_null :alchemical_properties, :effect_type, false
  end
end
