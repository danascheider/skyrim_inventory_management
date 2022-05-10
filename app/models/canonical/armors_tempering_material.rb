# frozen_string_literal: true

module Canonical
  class ArmorsTemperingMaterial < ApplicationRecord
    self.table_name = 'canonical_armors_tempering_materials'

    belongs_to :armor, class_name: 'Canonical::Armor', inverse_of: :canonical_armors_tempering_materials
    belongs_to :material, class_name: 'Canonical::Material', inverse_of: :canonical_armors_tempering_materials

    validates :material_id, uniqueness: { scope: :armor_id, message: 'must form a unique combination with canonical armor item' }
    validates :quantity, numericality: { greater_than: 0, only_integer: true }
  end
end
