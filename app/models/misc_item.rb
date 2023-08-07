# frozen_string_literal: true

class MiscItem < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_misc_item,
             optional: true,
             inverse_of: :misc_items,
             class_name: 'Canonical::MiscItem'

  validates :name, presence: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validate :validate_association

  before_validation :set_canonical_misc_item

  DUPLICATE_MESSAGE = 'is a duplicate of a unique in-game item'
  DOES_NOT_MATCH = "doesn't match any item that exists in Skyrim"

  def canonical_models
    return [] if name.blank?
    return [canonical_misc_item] if canonical_misc_item.present?

    canonicals = Canonical::MiscItem.where('name ILIKE ?', name)

    attributes_to_match.any? ? canonicals.where(**attributes_to_match) : canonicals
  end

  private

  def set_canonical_misc_item
    return if canonical_models.blank?
    return if canonical_models.count > 1 && unit_weight.blank?

    associate_first_available_match

    return if canonical_misc_item.blank?

    self.name = canonical_misc_item.name
    self.unit_weight = canonical_misc_item.unit_weight
  end

  def associate_first_available_match
    return if canonical_misc_item.present?

    canonical_models.each do |model|
      next if model.unique_item && model.misc_items.where(game_id:).any?

      self.canonical_misc_item = model
      break
    end
  end

  def validate_association
    return unless canonical_misc_item.nil?
    return if canonical_models.count > 1 && unit_weight.blank?

    error_msg = canonical_models.any? ? DUPLICATE_MESSAGE : DOES_NOT_MATCH
    errors.add(:base, error_msg)
  end

  def attributes_to_match
    { unit_weight: }.compact
  end
end
