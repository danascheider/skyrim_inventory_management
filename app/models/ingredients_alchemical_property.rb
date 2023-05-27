# frozen_string_literal: true

class IngredientsAlchemicalProperty < ApplicationRecord
  belongs_to :ingredient
  belongs_to :alchemical_property

  validates :alchemical_property_id,
            uniqueness: {
              scope: :ingredient_id,
              message: 'must form a unique combination with ingredient',
            }
  validates :priority,
            allow_blank: true,
            uniqueness: {
              scope: :ingredient_id,
              message: 'must be unique per ingredient',
            },
            numericality: {
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 4,
              only_integer: true,
            }
  validates :strength_modifier,
            allow_blank: true,
            numericality: { greater_than: 0 }
  validates :duration_modifier,
            allow_blank: true,
            numericality: { greater_than: 0 }
  validate :ensure_match_exists
  validate :ensure_max_of_four_per_ingredient

  before_validation :set_attributes_from_canonical, if: -> { canonical_model.present? }

  delegate :canonical_ingredients, to: :ingredient

  DOES_NOT_MATCH = 'is not consistent with any ingredient that exists in Skyrim'

  def canonical_models
    matching_attrs = {
      alchemical_property_id:,
      ingredient_id: canonical_ingredients.ids,
      strength_modifier:,
      duration_modifier:,
      priority:,
    }.compact

    Canonical::IngredientsAlchemicalProperty.where(**matching_attrs)
  end

  def canonical_model
    @canonical_model ||= begin
      models = canonical_models
      models.first if models.count == 1
    end
  end

  private

  def ensure_max_of_four_per_ingredient
    return if ingredient.alchemical_properties.length < Canonical::IngredientsAlchemicalProperty::MAX_PER_INGREDIENT

    errors.add(
      :ingredient,
      "already has #{Canonical::IngredientsAlchemicalProperty::MAX_PER_INGREDIENT} alchemical properties",
    )
  end

  def set_attributes_from_canonical
    return if canonical_model.nil?

    self.priority = canonical_model.priority
    self.strength_modifier = canonical_model.strength_modifier
    self.duration_modifier = canonical_model.duration_modifier
  end

  def ensure_match_exists
    return if canonical_models.any?

    errors.add(:base, DOES_NOT_MATCH)
  end
end
