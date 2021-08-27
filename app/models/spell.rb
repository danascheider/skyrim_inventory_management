# frozen_string_literal: true

class Spell < ApplicationRecord
  SCHOOLS = %w[
              Alteration
              Conjuration
              Destruction
              Illusion
              Restoration
            ].freeze

  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :school, presence: true, inclusion: { in: SCHOOLS, message: 'must be a valid school of magic' }
  validates :description, presence: true
end
