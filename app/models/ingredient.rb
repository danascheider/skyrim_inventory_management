# frozen_string_literal: true

class Ingredient < ApplicationRecord
  DOES_NOT_MATCH = "doesn't match an ingredient that exists in Skyrim"

  belongs_to :game
  belongs_to :canonical_ingredient,
             class_name: 'Canonical::Ingredient',
             optional: true,
             inverse_of: :ingredients

  has_many :ingredients_alchemical_properties, dependent: :destroy, inverse_of: :ingredient
  has_many :alchemical_properties,
           -> { select 'alchemical_properties.*, ingredients_alchemical_properties.priority' },
           through: :ingredients_alchemical_properties

  validates :name, presence: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validate :ensure_match_exists

  before_validation :set_canonical_ingredient

  def canonical_ingredients
    return Canonical::Ingredient.where(id: canonical_ingredient.id) if canonical_ingredient.present?

    matching = Canonical::Ingredient.where('name ILIKE ?', name)
    matching = matching.where(**attributes_to_match) if attributes_to_match.any?

    return matching if alchemical_properties.empty?

    ingredients_alchemical_properties.each do |join_model|
      matching = matching.joins(:canonical_ingredients_alchemical_properties).where(
        'canonical_ingredients_alchemical_properties.alchemical_property_id = :property_id AND canonical_ingredients_alchemical_properties.priority = :priority',
        property_id: join_model.alchemical_property_id,
        priority: join_model.priority,
      )
    end

    matching
  end

  private

  def set_canonical_ingredient
    return if canonical_ingredient.present?

    canonicals = canonical_ingredients
    self.canonical_ingredient = canonicals.first if canonicals.count == 1

    return if canonical_ingredient.nil?

    self.name = canonical_ingredient.name
    self.unit_weight = canonical_ingredient.unit_weight
  end

  def ensure_match_exists
    return if canonical_ingredients.any?

    errors.add(:base, DOES_NOT_MATCH)
  end

  def attributes_to_match
    { unit_weight: }.compact
  end
end
