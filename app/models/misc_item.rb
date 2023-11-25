# frozen_string_literal: true

class MiscItem < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_misc_item,
             optional: true,
             inverse_of: :misc_items,
             class_name: 'Canonical::MiscItem'

  validates :name, presence: true
  validates :unit_weight,
            numericality: {
              greater_than_or_equal_to: 0,
              allow_nil: true,
            }

  validate :validate_association
  validate :validate_unique_canonical

  before_validation :set_canonical_misc_item

  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'
  DOES_NOT_MATCH = "doesn't match any item that exists in Skyrim"

  def canonical_model
    canonical_misc_item
  end

  def canonical_models
    return Canonical::MiscItem.where(id: canonical_misc_item_id) if canonical_model_matches?

    canonicals = Canonical::MiscItem.where('name ILIKE ?', name)

    attributes_to_match.any? ? canonicals.where(**attributes_to_match) : canonicals
  end

  private

  def set_canonical_misc_item
    canonicals = canonical_models

    unless canonicals.count == 1
      clear_canonical_misc_item
      return
    end

    self.canonical_misc_item = canonicals.first
    self.name = canonical_misc_item.name
    self.unit_weight = canonical_misc_item.unit_weight
  end

  def validate_association
    return unless canonical_misc_item.nil?
    return if canonical_models.count > 1 && unit_weight.blank?

    error_msg = canonical_models.any? ? DUPLICATE_MATCH : DOES_NOT_MATCH
    errors.add(:base, error_msg)
  end

  def validate_unique_canonical
    return unless canonical_misc_item&.unique_item

    items = canonical_misc_item.misc_items.where(game_id:)

    return if items.count < 1
    return if items.count == 1 && items.first == self

    errors.add(:base, DUPLICATE_MATCH)
  end

  def clear_canonical_misc_item
    self.canonical_misc_item_id = nil
  end

  def canonical_model_matches?
    return false if canonical_model.nil?
    return false unless name.casecmp(canonical_model.name).zero?
    return false unless unit_weight.nil? || unit_weight == canonical_model.unit_weight

    true
  end

  def attributes_to_match
    { unit_weight: }.compact
  end
end
