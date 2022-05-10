# frozen_string_literal: true

module Canonical
  class ArmorsEnchantment < ApplicationRecord
    self.table_name = 'canonical_armors_enchantments'

    belongs_to :armor, class_name: 'Canonical::Armor', inverse_of: :canonical_armors_enchantments
    belongs_to :enchantment

    validates :enchantment_id, uniqueness: { scope: :armor_id, message: 'must form a unique combination with canonical armor item' }
  end
end
