# frozen_string_literal: true

class CanonicalMaterial < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0 }
end
