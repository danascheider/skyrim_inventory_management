# frozen_string_literal: true

class CanonicalJewelryItemsEnchantment < ApplicationRecord
  belongs_to :canonical_jewelry_item
  belongs_to :enchantment
end
