# frozen_string_literal: true

class CanonicalJewelryItem < ApplicationRecord
  has_many :enchantments, through: :canonical_jewelry_items_enchantments

  validates :name, presence: true, uniqueness: true
  validates :jewelry_type,
            presence:  true,
            inclusion: { in: %w[ring circlet amulet], message: 'must be "ring", "circlet", or "amulet"' }
  validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
