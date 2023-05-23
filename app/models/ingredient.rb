# frozen_string_literal: true

class Ingredient < ApplicationRecord
  DOES_NOT_MATCH = "doesn't match an ingredient that exists in Skyrim"

  belongs_to :game
  belongs_to :canonical_ingredient,
             class_name: 'Canonical::Ingredient',
             optional: true,
             inverse_of: :ingredients

  validates :name, presence: true
  validate :ensure_match_exists

  before_validation :set_canonical_ingredient

  private

  def set_canonical_ingredient
    matching = Canonical::Ingredient.where('name ILIKE ?', name)

    self.canonical_ingredient = matching.first if matching.count == 1
  end

  def ensure_match_exists
    return if canonical_ingredient.present?
    return if Canonical::Ingredient.where('name ILIKE ?', name).present?

    errors.add(:base, DOES_NOT_MATCH)
  end
end
