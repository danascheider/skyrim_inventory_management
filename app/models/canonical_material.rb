# frozen_string_literal: true

class CanonicalMaterial < ApplicationRecord
  has_many :smithable_armors, through: :canonical_armors_smithing_materials, source: :canonical_armor
  has_many :temperable_armors, through: :canonical_armors_tempering_materials, source: :canonical_armor
  has_many :canonical_jewelry_items, through: :canonical_jewelry_items_canonical_materials

  validates :name, presence: true
  validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
  validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
