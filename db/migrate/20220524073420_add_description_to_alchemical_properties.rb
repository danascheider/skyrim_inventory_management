# frozen_string_literal: true

class AddDescriptionToAlchemicalProperties < ActiveRecord::Migration[6.1]
  def change
    add_column :alchemical_properties, :description, :string, null: false
  end
end
