# frozen_string_literal: true

class CanonicalArmorsSmithingMaterial < ApplicationRecord
  belongs_to :canonical_armor
  belongs_to :canonical_material

  validates :canonical_armor_id, presence: true
  validates :canonical_material_id, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
