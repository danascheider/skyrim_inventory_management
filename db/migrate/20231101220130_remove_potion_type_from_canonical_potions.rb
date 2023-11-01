# frozen_string_literal: true

class RemovePotionTypeFromCanonicalPotions < ActiveRecord::Migration[7.1]
  def change
    remove_column :canonical_potions, :potion_type, :string, null: false
  end
end
