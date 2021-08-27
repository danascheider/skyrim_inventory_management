# frozen_string_literal: true

class Spell < ApplicationRecord
  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :description, presence: true
end
