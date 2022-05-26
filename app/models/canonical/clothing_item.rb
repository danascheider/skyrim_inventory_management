# frozen_string_literal: true

module Canonical
  class ClothingItem < ApplicationRecord
    self.table_name = 'canonical_clothing_items'

    has_many :canonical_enchantables_enchantments,
             dependent:  :destroy,
             class_name: 'Canonical::EnchantablesEnchantment',
             as:         :enchantable
    has_many :enchantments,
             -> { select 'enchantments.*, canonical_enchantables_enchantments.strength as strength' },
             through: :canonical_enchantables_enchantments

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :body_slot,
              presence:  true,
              inclusion: { in: %w[head hands body feet], message: 'must be "head", "hands", "body", or "feet"' }

    def self.unique_identifier
      :item_code
    end
  end
end
