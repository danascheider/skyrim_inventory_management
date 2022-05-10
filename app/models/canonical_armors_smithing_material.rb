# frozen_string_literal: true

class CanonicalArmorsSmithingMaterial < ApplicationRecord
  belongs_to :canonical_armor, class_name: 'Canonical::Armor'
  belongs_to :canonical_material

  validates :canonical_armor_id, uniqueness: { scope: :canonical_material_id, message: 'must form a unique combination with canonical material' }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
