# frozen_string_literal: true

class IngredientsAlchemicalProperty < ApplicationRecord
  belongs_to :ingredient
  belongs_to :alchemical_property

  validates :alchemical_property_id, uniqueness: { scope: :ingredient_id, message: 'must form a unique combination with ingredient' }
  validates :priority,
            allow_blank: true,
            uniqueness: { scope: :ingredient_id, message: 'must be unique per ingredient' },
            numericality: {
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 4,
              only_integer: true,
            }
  validates :strength_modifier, allow_blank: true, numericality: { greater_than: 0 }
  validates :duration_modifier, allow_blank: true, numericality: { greater_than: 0 }
  validate :ensure_max_of_four_per_ingredient, on: :create

  MAX_PER_INGREDIENT = 4

  def ensure_max_of_four_per_ingredient
    return if ingredient.nil?
    return if ingredient.alchemical_properties.length < MAX_PER_INGREDIENT

    errors.add(:ingredient, "already has #{MAX_PER_INGREDIENT} alchemical properties")
  end
end
