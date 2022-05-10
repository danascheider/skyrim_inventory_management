# frozen_string_literal: true

module Canonical
  class ArmorsEnchantment < ApplicationRecord
    self.table_name = 'canonical_armors_enchantments'

    belongs_to :canonical_armor, class_name: 'Canonical::Armor', inverse_of: :canonical_armors_enchantments
    belongs_to :enchantment

    validates :enchantment_id, uniqueness: { scope: :canonical_armor_id, message: 'must form a unique combination with canonical armor item' }
  end
end
