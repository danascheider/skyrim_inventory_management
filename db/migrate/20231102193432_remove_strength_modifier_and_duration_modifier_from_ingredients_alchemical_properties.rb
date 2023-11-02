# frozen_string_literal: true

class RemoveStrengthModifierAndDurationModifierFromIngredientsAlchemicalProperties < ActiveRecord::Migration[7.1]
  def change
    remove_column :ingredients_alchemical_properties, :strength_modifier, :decimal
    remove_column :ingredients_alchemical_properties, :duration_modifier, :decimal
  end
end
