# frozen_string_literal: true

class Staff < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_staff, optional: true, class_name: 'Canonical::Potion'

  validates :name, presence: true
end
