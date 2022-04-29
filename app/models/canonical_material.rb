# frozen_string_literal: true

class CanonicalMaterial < ApplicationRecord
  has_many :smithable_armors, through: :canonical_armors_smithing_materials, source: :canonical_armor
  has_many :temperable_armors, through: :canonical_armors_tempering_materials, source: :canonical_armor

  validates :name, presence: true, uniqueness: true
  validates :unit_weight, allow_blank: true, numericality: { greater_than_or_equal_to: 0 }
end
