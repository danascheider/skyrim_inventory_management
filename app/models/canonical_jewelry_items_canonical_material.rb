# frozen_string_literal: true

class CanonicalJewelryItemsCanonicalMaterial < ApplicationRecord
  belongs_to :canonical_jewelry_item
  belongs_to :canonical_material

  validates :count, numericality: { greater_than: 0, only_integer: true }
end
