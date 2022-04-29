# frozen_string_literal: true

class CanonicalClothingItem < ApplicationRecord
  has_many :enchantments, through: :canonical_clothing_items_enchantments

  validates :name, presence: true, uniqueness: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0 }
end
