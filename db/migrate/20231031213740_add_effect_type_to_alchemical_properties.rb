# frozen_string_literal: true

class AddEffectTypeToAlchemicalProperties < ActiveRecord::Migration[7.1]
  def change
    add_column :alchemical_properties, :effect_type, :string
  end
end
