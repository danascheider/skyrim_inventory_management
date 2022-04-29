# frozen_string_literal: true

class CanonicalClothingItemsEnchantment < ApplicationRecord
  belongs_to :canonical_clothing_item
  belongs_to :enchantment
end
