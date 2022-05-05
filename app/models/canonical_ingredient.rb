# frozen_string_literal: true

class CanonicalIngredient < ApplicationRecord
  has_many :alchemical_properties_canonical_ingredients, dependent: :destroy
  has_many :alchemical_properties, through: :alchemical_properties_canonical_ingredients

  validates :name, presence: true
  validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
  validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
