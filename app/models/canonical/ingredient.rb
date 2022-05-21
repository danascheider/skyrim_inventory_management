# frozen_string_literal: true

module Canonical
  class Ingredient < ApplicationRecord
    self.table_name = 'canonical_ingredients'

    has_many :canonical_ingredients_alchemical_properties,
             dependent:  :destroy,
             class_name: 'Canonical::IngredientsAlchemicalProperty'
    has_many :alchemical_properties, through: :canonical_ingredients_alchemical_properties

    has_many :canonical_recipes_ingredients,
             dependent:  :destroy,
             class_name: 'Canonical::RecipesIngredient',
             inverse_of: :ingredient
    has_many :recipes, through: :canonical_recipes_ingredients, class_name: 'Canonical::Book', source: :recipe

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def self.unique_identifier
      :item_code
    end
  end
end
