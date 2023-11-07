# frozen_string_literal: true

class ClothingItemValidator < ActiveModel::Validator
  NO_CANONICAL_MATCHES = "doesn't match a clothing item that exists in Skyrim"
  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'

  def validate(record)
    @record = record

    if @record.canonical_models.none?
      @record.errors.add(:base, NO_CANONICAL_MATCHES)
      return
    end

    validate_unique_canonical
  end

  private

  attr_reader :record

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
