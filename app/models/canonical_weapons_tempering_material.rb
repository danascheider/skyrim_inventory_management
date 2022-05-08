# frozen_string_literal: true

class CanonicalWeaponsTemperingMaterial < ApplicationRecord
  belongs_to :canonical_weapon
  belongs_to :canonical_material

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :canonical_weapon_id, uniqueness: { scope: :canonical_material_id, message: 'must form a unique combination with canonical material' }
end
