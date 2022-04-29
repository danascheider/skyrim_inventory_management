# frozen_string_literal: true

class CanonicalArmorsTemperingMaterial < ApplicationRecord
  belongs_to :canonical_armor
  belongs_to :canonical_material

  validates :count, presence: true, numericality: { greater_than: 0, only_integer: true }
end
