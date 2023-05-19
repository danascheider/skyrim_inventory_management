# frozen_string_literal: true

module Canonical
  class EnchantablesEnchantment < ApplicationRecord
    self.table_name = 'canonical_enchantables_enchantments'

    belongs_to :enchantable, polymorphic: true
    belongs_to :enchantment

    validates :enchantment_id, uniqueness: { scope: %i[enchantable_id enchantable_type], message: 'must form a unique combination with enchantable item' }
  end
end
