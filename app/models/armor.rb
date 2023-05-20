# frozen_string_literal: true

class Armor < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_armor, optional: true, class_name: 'Canonical::Armor'

  validates :name, presence: true
end
