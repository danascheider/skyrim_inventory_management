# frozen_string_literal: true

class CanonicalArmorsTemperingMaterial < ApplicationRecord
  belongs_to :canonical_armor
  belongs_to :canonical_material

  validates :canonical_material_id, uniqueness: { scope: :canonical_armor_id, message: 'must form a unique combination with canonical armor item' }
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
end
