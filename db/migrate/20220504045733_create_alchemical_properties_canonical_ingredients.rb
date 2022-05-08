# frozen_string_literal: true

class CreateAlchemicalPropertiesCanonicalIngredients < ActiveRecord::Migration[6.1]
  def change
    create_table :alchemical_properties_canonical_ingredients do |t|
      t.references :alchemical_property,
                   null:        false,
                   foreign_key: true,
                   index:       { name: 'index_alc_properties_can_ingredients_on_alc_property_id' }
      t.references :canonical_ingredient,
                   null:        false,
                   foreign_key: true,
                   index:       { name: 'index_alc_properties_can_ingredients_on_can_ingredient_id' }

      t.index %i[alchemical_property_id canonical_ingredient_id], unique: true, name: 'index_alc_properties_can_ingredients_on_property_and_ingr_ids'

      t.timestamps
    end
  end
end
