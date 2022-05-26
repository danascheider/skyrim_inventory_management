# frozen_string_literal: true

require 'skyrim'

module Canonical
  class Weapon < ApplicationRecord
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

    self.table_name = 'canonical_weapons'

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

    validate :verify_category_type_combination
    validate :verify_all_smithing_perks_valid

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
  end
end
