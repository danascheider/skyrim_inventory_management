# frozen_string_literal: true

class Armor < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_armor, optional: true, class_name: 'Canonical::Armor'

  validates :name, presence: true

  def canonical_armors
    return Array.wrap(canonical_armor) if canonical_armor

    attrs_to_match = { unit_weight:, weight:, magical_effects: }.compact

    canonicals = Canonical::Armor.where('name ILIKE ?', name)
    attrs_to_match.any? ? canonicals.where(**attrs_to_match) : canonicals
  end
end
