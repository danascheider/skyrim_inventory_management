# frozen_string_literal: true

class MiscItem < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_misc_item,
             optional: true,
             inverse_of: :misc_items,
             class_name: 'Canonical::MiscItem'

  validates :name, presence: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def canonical_models
    return [canonical_misc_item] if canonical_misc_item.present?

    canonicals = Canonical::MiscItem.where('name ILIKE ?', name)

    attributes_to_match.any? ? canonicals.where(**attributes_to_match) : canonicals
  end

  private

  def attributes_to_match
    { unit_weight: }.compact
  end
end
