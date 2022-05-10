# frozen_string_literal: true

module Canonical
  class JewelryItemsMaterial < ApplicationRecord
    self.table_name = 'canonical_jewelry_items_materials'

    belongs_to :canonical_jewelry_item, class_name: 'Canonical::JewelryItem'
    belongs_to :canonical_material, class_name: 'Canonical::Material'

    validates :quantity, numericality: { greater_than: 0, only_integer: true }
    validates :canonical_jewelry_item_id, uniqueness: { scope: :canonical_material_id, message: 'must form a unique combination with canonical material' }
  end
end
