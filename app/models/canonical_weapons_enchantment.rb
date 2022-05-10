# frozen_string_literal: true

class CanonicalWeaponsEnchantment < ApplicationRecord
  belongs_to :canonical_weapon, class_name: 'Canonical::Weapon'
  belongs_to :enchantment

  validates :strength, numericality: { greater_than: 0, allow_blank: true }
  validates :enchantment_id, uniqueness: { scope: :canonical_weapon_id, message: 'must form a unique combination with canonical weapon' }
end
