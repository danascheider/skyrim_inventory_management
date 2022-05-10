# frozen_string_literal: true

module Canonical
  class WeaponsSmithingMaterial < ApplicationRecord
    self.table_name = 'canonical_weapons_smithing_materials'

    belongs_to :weapon, class_name: 'Canonical::Weapon'
    belongs_to :material, class_name: 'Canonical::Material'

    validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
    validates :weapon_id, uniqueness: { scope: :material_id, message: 'must form a unique combination with canonical material' }
  end
end
