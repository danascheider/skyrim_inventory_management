# frozen_string_literal: true

class ArmorValidator < ActiveModel::Validator
  NO_CANONICAL_MATCHES = "doesn't match an armor item that exists in Skyrim"
  DOES_NOT_MATCH = 'does not match value on canonical model'
  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'

  def validate(record)
    @record = record

    if @record.canonical_models.blank?
      @record.errors.add(:base, NO_CANONICAL_MATCHES)
      return
    end

    validate_unique_canonical_match if @record.canonical_model.present?
  end

  private

  attr_reader :record

  def validate_unique_canonical_match
    return unless record.canonical_armor&.unique_item

    armors = record.canonical_armor.armors.where(game_id: record.game_id)

    return if armors.count < 1
    return if armors.count == 1 && armors.first == record

    record.errors.add(:base, DUPLICATE_MATCH)
  end
end
