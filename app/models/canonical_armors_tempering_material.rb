# frozen_string_literal: true

class CanonicalArmorsTemperingMaterial < ApplicationRecord
  belongs_to :canonical_armor
  belongs_to :canonical_material

  validates :canonical_armor_id, presence: true
  validates :canonical_material_id, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
end
