# frozen_string_literal: true

class AlchemicalPropertiesCanonicalIngredient < ApplicationRecord
  belongs_to :alchemical_property
  belongs_to :canonical_ingredient

  validates :alchemical_property_id, uniqueness: { scope: :canonical_ingredient_id, message: 'must form a unique combination with canonical ingredient' }
  validates :priority, uniqueness: { scope: :canonical_ingredient_id, message: 'must be unique per ingredient' }
  validate :ensure_max_of_four_per_ingredient, on: :create

  MAX_PER_INGREDIENT = 4

  private

  def ensure_max_of_four_per_ingredient
    errors.add(:canonical_ingredient, "already has #{MAX_PER_INGREDIENT} alchemical properties") if canonical_ingredient.alchemical_properties.count >= MAX_PER_INGREDIENT
  end
end
