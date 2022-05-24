# frozen_string_literal: true

class AlchemicalProperty < ApplicationRecord
  has_many :canonical_ingredients_alchemical_properties,
           dependent:  :destroy,
           class_name: 'Canonical::IngredientsAlchemicalProperty'
  has_many :canonical_ingredients, through: :canonical_ingredients_alchemical_properties

  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :description, presence: true
  validates :strength_unit, inclusion: { in: %w[point percentage], message: 'must be "point" or "percentage"', allow_blank: true }

  def self.unique_identifier
    :name
  end
end
