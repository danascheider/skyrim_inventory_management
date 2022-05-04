# frozen_string_literal: true

class CanonicalJewelryItemsEnchantment < ApplicationRecord
  belongs_to :canonical_jewelry_item
  belongs_to :enchantment

  validates :canonical_jewelry_item_id, uniqueness: { scope: :enchantment_id, message: 'must form a unique combination with enchantment' }
  validates :strength, allow_blank: true, numericality: { greater_than: 0 }
end
