# frozen_string_literal: true

class ClothingItem < ApplicationRecord
  belongs_to :game

  belongs_to :canonical_clothing_item,
             optional: true,
             inverse_of: :clothing_items,
             class_name: 'Canonical::ClothingItem'

  has_many :enchantables_enchantments,
           dependent: :destroy,
           as: :enchantable
  has_many :enchantments,
           -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
           through: :enchantables_enchantments,
           source: :enchantment

  validates :name, presence: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
