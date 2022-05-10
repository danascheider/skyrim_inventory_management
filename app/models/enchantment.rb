# frozen_string_literal: true

class Enchantment < ApplicationRecord
  SCHOOLS = %w[
              Alteration
              Conjuration
              Destruction
              Illusion
              Restoration
            ].freeze

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
                          'pickaxe',
                        ].freeze

  ENCHANTABLE_APPAREL_ITEMS = %w[
                                head
                                chest
                                hands
                                feet
                                shield
                                amulet
                                ring
                              ].freeze

  ENCHANTABLE_ITEMS = (ENCHANTABLE_WEAPONS + ENCHANTABLE_APPAREL_ITEMS).freeze

  STRENGTH_UNITS = %w[percentage point second level].freeze

  has_many :canonical_armors_enchantments, class_name: 'Canonical::ArmorsEnchantment', dependent: :destroy
  has_many :canonical_armors, through: :canonical_armors_enchantments

  has_many :canonical_clothing_items_enchantments, class_name: 'Canonical::ClothingItemsEnchantment', dependent: :destroy
  has_many :canonical_clothing_items, through: :canonical_clothing_items_enchantments

  has_many :canonical_jewelry_items_enchantments, class_name: 'Canonical::JewelryItemsEnchantment', dependent: :destroy
  has_many :canonical_jewelry_items, through: :canonical_jewelry_items_enchantments

  has_many :canonical_weapons_enchantments, class_name: 'Canonical::WeaponsEnchantment', dependent: :destroy
  has_many :canonical_weapons, through: :canonical_weapons_enchantments

  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :strength_unit,
            inclusion: {
                         in:          STRENGTH_UNITS,
                         message:     'must be "point", "percentage", "second", or the "level" of affected targets',
                         allow_blank: true,
                       }
  validates :school, inclusion: { in: SCHOOLS, message: 'must be a valid school of magic', allow_blank: true }
  validate :validate_enchantable_items

  private

  def validate_enchantable_items
    errors.add(:enchantable_items, 'must consist of valid enchantable item types') unless enchantable_items.all? {|item| ENCHANTABLE_ITEMS.include?(item) }
  end
end
