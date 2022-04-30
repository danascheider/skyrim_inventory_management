# frozen_string_literal: true

class CanonicalJewelryItem < ApplicationRecord
  has_many :enchantments, through: :canonical_jewelry_items_enchantments
  has_many :canonical_materials, through: :canonical_jewelry_items_canonical_materials

  validates :name, presence: true
  validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
  validates :jewelry_type,
            presence:  true,
            inclusion: { in: %w[ring circlet amulet], message: 'must be "ring", "circlet", or "amulet"' }
  validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
