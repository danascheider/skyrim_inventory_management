# frozen_string_literal: true

class JewelryItem < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_jewelry_item,
             optional: true,
             inverse_of: :jewelry_items,
             class_name: 'Canonical::JewelryItem'

  validates :name, presence: true
  validates :jewelry_type,
            allow_blank: true,
            inclusion: {
              in: Canonical::JewelryItem::JEWELRY_TYPES,
              message: Canonical::JewelryItem::JEWELRY_TYPE_VALIDATION_MESSAGE,
            }
  validates :unit_weight,
            allow_blank: true,
            numericality: {
              greater_than_or_equal_to: 0,
            }

  def crafting_materials
    canonical_jewelry_item&.crafting_materials
  end
end
