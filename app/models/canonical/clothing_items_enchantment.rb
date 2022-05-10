# frozen_string_literal: true

module Canonical
  class ClothingItemsEnchantment < ApplicationRecord
    self.table_name = 'canonical_clothing_items_enchantments'

    belongs_to :clothing_item, class_name: 'Canonical::ClothingItem'
    belongs_to :enchantment

    validates :clothing_item_id, uniqueness: { scope: :enchantment_id, message: 'must form a unique combination with enchantment' }
    validates :strength, allow_blank: true, numericality: { greater_than: 0 }
  end
end
