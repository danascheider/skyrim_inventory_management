# frozen_string_literal: true

class CanonicalClothingItemsEnchantment < ApplicationRecord
  belongs_to :canonical_clothing_item
  belongs_to :enchantment

  validates :canonical_clothing_item_id, presence: true
  validates :enchantment_id, presence: true
  validates :strength, allow_blank: true, numericality: { greater_than: 0 }
end
