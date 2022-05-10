# frozen_string_literal: true

module Canonical
  class Ingredient < ApplicationRecord
    self.table_name = 'canonical_ingredients'

    has_many :canonical_ingredients_alchemical_properties,
             dependent:   :destroy,
             class_name:  'Canonical::IngredientsAlchemicalProperty',
             foreign_key: :canonical_ingredient_id,
             inverse_of:  :canonical_ingredient
    has_many :alchemical_properties, through: :canonical_ingredients_alchemical_properties

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
  end
end
