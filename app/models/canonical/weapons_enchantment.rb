# frozen_string_literal: true

module Canonical
  class WeaponsEnchantment < ApplicationRecord
    self.table_name = 'canonical_weapons_enchantments'

    belongs_to :weapon, class_name: 'Canonical::Weapon'
    belongs_to :enchantment

    validates :strength, numericality: { greater_than: 0, allow_blank: true }
    validates :enchantment_id, uniqueness: { scope: :weapon_id, message: 'must form a unique combination with canonical weapon' }
  end
end
