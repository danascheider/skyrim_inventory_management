# frozen_string_literal: true

module Canonical
  class ArmorsTemperingMaterial < ApplicationRecord
    self.table_name = 'canonical_armors_tempering_materials'

    belongs_to :canonical_armor, class_name: 'Canonical::Armor', inverse_of: :canonical_armors_tempering_materials
    belongs_to :canonical_material, class_name: 'Canonical::Material', inverse_of: :canonical_armors_tempering_materials

    validates :canonical_material_id, uniqueness: { scope: :canonical_armor_id, message: 'must form a unique combination with canonical armor item' }
    validates :quantity, numericality: { greater_than: 0, only_integer: true }
  end
end
