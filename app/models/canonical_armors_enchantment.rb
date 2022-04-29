# frozen_string_literal: true

class CanonicalArmorsEnchantment < ApplicationRecord
  belongs_to :canonical_armor
  belongs_to :enchantment
end
