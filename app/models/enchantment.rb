# frozen_string_literal: true

class Enchantment < ApplicationRecord
  ENCHANTABLE_WEAPONS = [
                          'sword',
                          'mace',
                          'war axe',
                          'greatsword',
                          'warhammer',
                          'battleaxe',
                          'dagger',
                          'bow',
                          'crossbow',
                          'staff',
                          'axe',
                        ].freeze

  ENCHANTABLE_APPAREL_ITEMS = %w[
                                helmet
                                bracers
                                gauntlets
                                boots
                                shield
                                armor
                                robes
                                shoes
                                necklace
                                ring
                                circlet
                                gloves
                              ].freeze

  ENCHANTABLE_ITEMS = (ENCHANTABLE_WEAPONS + ENCHANTABLE_APPAREL_ITEMS).freeze

  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :strength_unit, presence: true, inclusion: { in: %w[point percentage], message: 'must be "point" or "percentage"' }
  validate :validate_enchantable_items

  private

  def validate_enchantable_items
    errors.add(:enchantable_items, 'must consist of valid enchantable item types') unless enchantable_items.all? {|item| ENCHANTABLE_ITEMS.include?(item) }
  end
end
