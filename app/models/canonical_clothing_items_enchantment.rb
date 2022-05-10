# frozen_string_literal: true

class CanonicalClothingItemsEnchantment < ApplicationRecord
  belongs_to :canonical_clothing_item, class_name: 'Canonical::ClothingItem'
  belongs_to :enchantment

  validates :canonical_clothing_item_id,  uniqueness: { scope: :enchantment_id, message: 'must form a unique combination with enchantment' }
  validates :strength, allow_blank: true, numericality: { greater_than: 0 }
end
