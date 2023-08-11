# frozen_string_literal: true

class Potion < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_potion, optional: true, class_name: 'Canonical::Potion'

  validates :name, presence: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0, allow_blank: true }

  before_validation :set_canonical_potion

  def canonical_models
    return Canonical::Potion.where(id: canonical_potion_id) if canonical_potion.present?

    canonicals = Canonical::Potion.where('name ILIKE ?', name)
    canonicals = canonicals.where(**attributes_to_match) if attributes_to_match.any?

    canonicals
  end

  private

  def attributes_to_match
    { unit_weight: }.compact
  end

  def set_canonical_potion
    return unless canonical_models.count == 1
    return if canonical_potion.present?

    self.canonical_potion = canonical_models.first
    self.name = canonical_potion.name
    self.unit_weight = canonical_potion.unit_weight
  end
end
