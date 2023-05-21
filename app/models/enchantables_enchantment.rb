# frozen_string_literal: true

class EnchantablesEnchantment < ApplicationRecord
  belongs_to :enchantable, polymorphic: true
  belongs_to :enchantment

  validates :enchantment_id, uniqueness: { scope: %i[enchantable_id enchantable_type], message: 'must form a unique combination with enchantable item' }
end
