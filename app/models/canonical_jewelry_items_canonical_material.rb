# frozen_string_literal: true

class CanonicalJewelryItemsCanonicalMaterial < ApplicationRecord
  belongs_to :canonical_jewelry_item
  belongs_to :canonical_material

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :canonical_jewelry_item_id, uniqueness: { scope: :canonical_material_id, message: 'must form a unique combination with canonical material' }
end
