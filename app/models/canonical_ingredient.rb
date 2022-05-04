# frozen_string_literal: true

class CanonicalIngredient < ApplicationRecord
  has_many :alchemical_properties_canonical_ingredient, dependent: :destroy
  has_many :alchemical_properties, through: :alchemical_properties_canonical_ingredient

  validates :name, presence: true
  validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
end
