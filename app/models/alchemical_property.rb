# frozen_string_literal: true

class AlchemicalProperty < ApplicationRecord
  has_and_belongs_to_many :canonical_ingredients

  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :strength_unit, inclusion: { in: %w[point percentage], message: 'must be "point" or "percentage"', allow_blank: true }
end
