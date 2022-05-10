# frozen_string_literal: true

module Canonical
  class JewelryItemsMaterial < ApplicationRecord
    self.table_name = 'canonical_jewelry_items_materials'

    belongs_to :jewelry_item, class_name: 'Canonical::JewelryItem'
    belongs_to :material, class_name: 'Canonical::Material'

    validates :quantity, numericality: { greater_than: 0, only_integer: true }
    validates :jewelry_item_id, uniqueness: { scope: :material_id, message: 'must form a unique combination with canonical material' }
  end
end
