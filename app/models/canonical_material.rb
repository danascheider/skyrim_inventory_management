# frozen_string_literal: true

class CanonicalMaterial < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
