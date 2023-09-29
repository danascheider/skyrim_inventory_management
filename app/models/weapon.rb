# frozen_string_literal: true

class Weapon < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_weapon,
             optional: true,
             class_name: 'Canonical::Weapon',
             inverse_of: :armors
end
