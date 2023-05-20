# frozen_string_literal: true

class Armor < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_armor, optional: true, class_name: 'Canonical::Armor'

  validates :name, presence: true
  validates :weight,
            inclusion: {
              in: Canonical::Armor::ARMOR_WEIGHTS,
              message: 'must be "light armor" or "heavy armor"',
              allow_nil: true,
            }

  validates :unit_weight,
            numericality: {
              greater_than_or_equal_to: 0,
              allow_nil: true,
            }

  def canonical_armors
    return Array.wrap(canonical_armor) if canonical_armor

    attrs_to_match = { unit_weight:, weight:, magical_effects: }.compact

    canonicals = Canonical::Armor.where('name ILIKE ?', name)
    attrs_to_match.any? ? canonicals.where(**attrs_to_match) : canonicals
  end
end
