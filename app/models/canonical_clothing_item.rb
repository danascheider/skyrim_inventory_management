# frozen_string_literal: true

class CanonicalClothingItem < ApplicationRecord
  has_many :enchantments, through: :canonical_clothing_items_enchantments

  validates :name, presence: true, uniqueness: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0 }
  validates :body_slot,
            presence:  true,
            inclusion: { in: %w[head hands body feet shield], message: 'must be "head", "hands", "body", "feet", or "shield"' }
end
