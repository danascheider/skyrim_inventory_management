# frozen_string_literal: true

class AddPriorityAndStrengthMultiplierToAlchemicalPropertiesCanonicalIngredients < ActiveRecord::Migration[6.1]
  def change
    add_column :alchemical_properties_canonical_ingredients,
               :priority,
               :integer,
               null: false
    add_column :alchemical_properties_canonical_ingredients,
               :strength_modifier,
               :decimal
    add_column :alchemical_properties_canonical_ingredients,
               :duration_modifier,
               :decimal
    add_index :alchemical_properties_canonical_ingredients,
              %i[priority canonical_ingredient_id],
              unique: true,
              name:   :index_alc_properties_can_ingrs_on_priority_and_ingr_id
  end
end
