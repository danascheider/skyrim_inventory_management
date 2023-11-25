# frozen_string_literal: true

class Staff < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_staff,
             optional: true,
             class_name: 'Canonical::Staff',
             inverse_of: :staves

  validates :name, presence: true
  validates :unit_weight,
            numericality: {
              greater_than_or_equal_to: 0,
              allow_nil: true,
            }

  validate :validate_canonical_models
  validate :validate_unique_canonical

  before_validation :set_canonical_staff

  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'
  DOES_NOT_MATCH = "doesn't match any item that exists in Skyrim"

  def spells
    canonical_staff&.spells || Spell.none
  end

  def powers
    canonical_staff&.powers || Power.none
  end

  def canonical_model
    canonical_staff
  end

  def canonical_models
    return Canonical::Staff.where(id: canonical_staff_id) if canonical_model_matches?

    query = 'name ILIKE :name'
    query += ' AND (magical_effects ILIKE :magical_effects)' unless magical_effects.nil?

    canonicals = Canonical::Staff.where(query, name:, magical_effects:)
    attributes_to_match.any? ? canonicals.where(**attributes_to_match) : canonicals
  end

  private

  def set_canonical_staff
    canonicals = canonical_models

    unless canonicals.count == 1
      clear_canonical_staff
      return
    end

    self.canonical_staff = canonicals.first
    self.name = canonical_staff.name
    self.unit_weight = canonical_staff.unit_weight
    self.magical_effects = canonical_staff.magical_effects
  end

  def attributes_to_match
    { unit_weight: }.compact
  end

  def validate_unique_canonical
    return unless canonical_staff&.unique_item

    staves = canonical_staff.staves.where(game_id:)

    return if staves.count < 1
    return if staves.count == 1 && staves.last == self

    errors.add(:base, DUPLICATE_MATCH)
  end

  def validate_canonical_models
    errors.add(:base, DOES_NOT_MATCH) if canonical_models.none?
    errors.add(:base, DUPLICATE_MATCH) if canonical_staff.nil? && canonical_models.count == 1
  end

  def clear_canonical_staff
    self.canonical_staff_id = nil
  end

  def canonical_model_matches?
    return false if canonical_model.nil?
    return false unless name.casecmp(canonical_model.name).zero?
    return false unless magical_effects.nil? || magical_effects.casecmp(canonical_model.magical_effects)&.zero?
    return false unless unit_weight.nil? || unit_weight == canonical_model.unit_weight

    true
  end
end
