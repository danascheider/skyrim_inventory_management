# frozen_string_literal: true

module Canonical
  class WeaponsTemperingMaterial < ApplicationRecord
    self.table_name = 'canonical_weapons_tempering_materials'

    belongs_to :canonical_weapon, class_name: 'Canonical::Weapon'
    belongs_to :canonical_material, class_name: 'Canonical::Material'

    validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
    validates :canonical_weapon_id, uniqueness: { scope: :canonical_material_id, message: 'must form a unique combination with canonical material' }
  end
end
