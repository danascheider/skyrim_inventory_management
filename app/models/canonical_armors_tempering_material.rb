# frozen_string_literal: true

class CanonicalArmorsTemperingMaterial < ApplicationRecord
  belongs_to :canonical_armor, class_name: 'Canonical::Armor'
  belongs_to :canonical_material, class_name: 'Canonical::Material'

  validates :canonical_material_id, uniqueness: { scope: :canonical_armor_id, message: 'must form a unique combination with canonical armor item' }
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
end
