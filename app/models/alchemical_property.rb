# frozen_string_literal: true

class AlchemicalProperty < ApplicationRecord
  VALID_STRENGTH_UNITS = %w[point percentage level].freeze

  has_many :canonical_ingredients_alchemical_properties,
           dependent: :destroy,
           class_name: 'Canonical::IngredientsAlchemicalProperty'
  has_many :canonical_ingredients, through: :canonical_ingredients_alchemical_properties

  has_many :canonical_potions_alchemical_properties,
           dependent: :destroy,
           class_name: 'Canonical::PotionsAlchemicalProperty'
  has_many :canonical_potions, through: :canonical_potions_alchemical_properties, source: :potion

  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :description, presence: true
  validates :strength_unit, inclusion: { in: VALID_STRENGTH_UNITS, message: 'must be "point", "percentage", or the "level" of affected targets', allow_blank: true }

  def self.unique_identifier
    :name
  end
end
