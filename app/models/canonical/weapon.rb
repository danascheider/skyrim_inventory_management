# frozen_string_literal: true

require 'skyrim'

module Canonical
  class Weapon < ApplicationRecord
    self.table_name = 'canonical_weapons'

    BOOLEAN_VALUES = [true, false].freeze
    BOOLEAN_VALIDATION_MESSAGE = 'must be true or false'
    VALID_WEAPON_TYPES = {
                           'one-handed' => [
                             'dagger',
                             'mace',
                             'other',
                             'sword',
                             'war axe',
                           ],
                           'two-handed' => %w[
                             battleaxe
                             greatsword
                             warhammer
                           ],
                           'archery'    => %w[
                             arrow
                             bolt
                             bow
                             crossbow
                           ],
                         }.freeze

    has_many :canonical_enchantables_enchantments,
             dependent:  :destroy,
             class_name: 'Canonical::EnchantablesEnchantment',
             as:         :enchantable
    has_many :enchantments,
             -> { select 'enchantments.*, canonical_enchantables_enchantments.strength as strength' },
             through: :canonical_enchantables_enchantments

    has_many :canonical_powerables_powers,
             dependent:  :destroy,
             class_name: 'Canonical::PowerablesPower',
             as:         :powerable
    has_many :powers, through: :canonical_powerables_powers

    has_many :canonical_craftables_crafting_materials,
             dependent:  :destroy,
             class_name: 'Canonical::CraftablesCraftingMaterial',
             as:         :craftable
    has_many :crafting_materials,
             -> { select 'canonical_materials.*, canonical_craftables_crafting_materials.quantity as quantity_needed' },
             through: :canonical_craftables_crafting_materials,
             source:  :material

    has_many :canonical_temperables_tempering_materials,
             dependent:  :destroy,
             class_name: 'Canonical::TemperablesTemperingMaterial',
             as:         :temperable
    has_many :tempering_materials,
             -> { select 'canonical_materials.*, canonical_temperables_tempering_materials.quantity as quantity_needed' },
             through: :canonical_temperables_tempering_materials,
             source:  :material

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :category,
              presence:  true,
              inclusion: {
                           in:      VALID_WEAPON_TYPES.keys,
                           message: 'must be "one-handed", "two-handed", or "archery"',
                         }
    validates :weapon_type,
              presence:  true,
              inclusion: {
                           in:      VALID_WEAPON_TYPES.values.flatten,
                           message: 'must be a valid type of weapon that occurs in Skyrim',
                         }
    validates :base_damage, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :purchasable, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :unique_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :rare_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :quest_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :leveled, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :enchantable, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }

    validate :verify_category_type_combination
    validate :verify_all_smithing_perks_valid
    validate :validate_unique_item_also_rare, if: -> { unique_item == true }

    before_validation :upcase_item_code, if: -> { item_code_changed? }

    def self.unique_identifier
      :item_code
    end

    private

    def verify_category_type_combination
      errors.add(:weapon_type, "is not included in category \"#{category}\"") unless VALID_WEAPON_TYPES[category]&.include?(weapon_type)
    end

    def verify_all_smithing_perks_valid
      smithing_perks&.each do |perk|
        errors.add(:smithing_perks, "\"#{perk}\" is not a valid smithing perk") unless Skyrim::SMITHING_PERKS.include?(perk)
      end
    end

    def validate_unique_item_also_rare
      errors.add(:rare_item, 'must be true if item is unique') unless rare_item == true
    end

    def upcase_item_code
      item_code.upcase!
    end
  end
end
