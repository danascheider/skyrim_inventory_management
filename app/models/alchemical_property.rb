# frozen_string_literal: true

class AlchemicalProperty < ApplicationRecord
  has_many :alchemical_properties_canonical_ingredients, dependent: :destroy
  has_many :canonical_ingredients, through: :alchemical_properties_canonical_ingredients

  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :strength_unit, inclusion: { in: %w[point percentage], message: 'must be "point" or "percentage"', allow_blank: true }
end
