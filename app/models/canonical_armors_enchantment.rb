# frozen_string_literal: true

class CanonicalArmorsEnchantment < ApplicationRecord
  belongs_to :canonical_armor, class_name: 'Canonical::Armor'
  belongs_to :enchantment

  validates :enchantment_id, uniqueness: { scope: :canonical_armor_id, message: 'must form a unique combination with canonical armor item' }
end
