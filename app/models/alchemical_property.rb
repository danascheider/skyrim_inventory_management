# frozen_string_literal: true

class AlchemicalProperty < ApplicationRecord
  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :strength_unit, inclusion: { in: %w[point percentage], message: 'must be "point" or "percentage"', allow_blank: true }
end
