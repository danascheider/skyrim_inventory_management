# frozen_string_literal: true

class CanonicalArmorsSmithingMaterial < ApplicationRecord
  belongs_to :canonical_armor
  belongs_to :canonical_material

  validates :count, numericality: { only_integer: true, greater_than: 0 }
end
