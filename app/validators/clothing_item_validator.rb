# frozen_string_literal: true

class ClothingItemValidator < ActiveModel::Validator
  NO_CANONICAL_MATCHES = "doesn't match a clothing item that exists in Skyrim"
  DOES_NOT_MATCH = 'does not match value on canonical model'
  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'

  def validate(record)
    @record = record

    if @record.canonical_models.blank?
      @record.errors.add(:base, NO_CANONICAL_MATCHES)
      return
    end

    validate_against_canonical if @record.canonical_clothing_item.present?
  end

  private

  attr_reader :record

  def validate_against_canonical
    canonical = record.canonical_clothing_item

    validate_unique_canonical

    record.errors.add(:unit_weight, DOES_NOT_MATCH) unless record.unit_weight == canonical.unit_weight
    record.errors.add(:magical_effects, DOES_NOT_MATCH) unless record.magical_effects == canonical.magical_effects
  end

  def validate_unique_canonical
    return unless record.canonical_clothing_item&.unique_item

    items = record
              .canonical_clothing_item
              .clothing_items
              .where(game_id: record.game_id)

    return if items.count < 1
    return if items.count == 1 && items.first == record

    record.errors.add(:base, DUPLICATE_MATCH)
  end
end
