# frozen_string_literal: true

module Canonical
  class JewelryItem < ApplicationRecord
    self.table_name = 'canonical_jewelry_items'

    has_many :canonical_jewelry_items_enchantments,
             dependent:   :destroy,
             class_name:  'Canonical::JewelryItemsEnchantment',
             foreign_key: 'canonical_jewelry_item_id',
             inverse_of:  :canonical_jewelry_item
    has_many :enchantments,
             -> { select 'enchantments.*, canonical_jewelry_items_enchantments.strength as enchantment_strength' },
             through: :canonical_jewelry_items_enchantments

    has_many :canonical_jewelry_items_materials,
             dependent:   :destroy,
             class_name:  'Canonical::JewelryItemsMaterial',
             foreign_key: 'canonical_jewelry_item_id',
             inverse_of:  :canonical_jewelry_item
    has_many :canonical_materials,
             -> { select 'canonical_materials.*, canonical_jewelry_items_materials.quantity as quantity_needed' },
             through: :canonical_jewelry_items_materials

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :jewelry_type,
              presence:  true,
              inclusion: { in: %w[ring circlet amulet], message: 'must be "ring", "circlet", or "amulet"' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
  end
end
