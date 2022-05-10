# frozen_string_literal: true

module Canonical
  class ArmorsSmithingMaterial < ApplicationRecord
    self.table_name = 'canonical_armors_smithing_materials'

    belongs_to :canonical_armor, class_name: 'Canonical::Armor', inverse_of: :canonical_armors_smithing_materials
    belongs_to :canonical_material, class_name: 'Canonical::Material', inverse_of: :canonical_armors_smithing_materials

    validates :canonical_armor_id, uniqueness: { scope: :canonical_material_id, message: 'must form a unique combination with canonical material' }
    validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  end
end
