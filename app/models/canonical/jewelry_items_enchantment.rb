# frozen_string_literal: true

module Canonical
  class JewelryItemsEnchantment < ApplicationRecord
    self.table_name = 'canonical_jewelry_items_enchantments'

    belongs_to :canonical_jewelry_item, class_name: 'Canonical::JewelryItem'
    belongs_to :enchantment, inverse_of: :canonical_jewelry_items_enchantments

    validates :canonical_jewelry_item_id, uniqueness: { scope: :enchantment_id, message: 'must form a unique combination with enchantment' }
    validates :strength, allow_blank: true, numericality: { greater_than: 0 }
  end
end
