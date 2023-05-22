# frozen_string_literal: true

class ClothingItemValidator < ActiveModel::Validator
  NO_CANONICAL_MATCHES = "doesn't match a clothing item that exists in Skyrim"
  DOES_NOT_MATCH = 'does not match value on canonical model'

  def validate(record)
    @record = record

    if @record.canonical_clothing_items.blank?
      @record.errors.add(:base, NO_CANONICAL_MATCHES)
      return
    end

    validate_against_canonical if @record.canonical_clothing_item.present?
  end

  private

  attr_reader :record

  def validate_against_canonical
    canonical = record.canonical_clothing_item

    record.errors.add(:unit_weight, DOES_NOT_MATCH) unless record.unit_weight == canonical.unit_weight
    record.errors.add(:magical_effects, DOES_NOT_MATCH) unless record.magical_effects == canonical.magical_effects
  end
end
