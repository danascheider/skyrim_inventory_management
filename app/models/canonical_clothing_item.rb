# frozen_string_literal: true

class CanonicalClothingItem < ApplicationRecord
  has_many :canonical_clothing_items_enchantments, dependent: :destroy
  has_many :enchantments, through: :canonical_clothing_items_enchantments

  validates :name, presence: true
  validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0 }
  validates :body_slot,
            presence:  true,
            inclusion: { in: %w[head hands body feet], message: 'must be "head", "hands", "body", or "feet"' }
end
