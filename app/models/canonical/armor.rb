# frozen_string_literal: true

require 'skyrim'

module Canonical
  class Armor < ApplicationRecord
    self.table_name = 'canonical_armors'

    ARMOR_WEIGHTS = ['light armor', 'heavy armor'].freeze
    BOOLEAN_VALUES = [true, false].freeze
    BOOLEAN_VALIDATION_MESSAGE = 'must be true or false'

    has_many :enchantables_enchantments,
             dependent: :destroy,
             as: :enchantable
    has_many :enchantments,
             -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
             through: :enchantables_enchantments,
             source: :enchantment

    has_many :canonical_craftables_crafting_materials,
             dependent: :destroy,
             class_name: 'Canonical::CraftablesCraftingMaterial',
             as: :craftable
    has_many :crafting_materials,
             -> { select 'canonical_materials.*, canonical_craftables_crafting_materials.quantity as quantity_needed' },
             through: :canonical_craftables_crafting_materials,
             source: :material

    has_many :canonical_temperables_tempering_materials,
             dependent: :destroy,
             class_name: 'Canonical::TemperablesTemperingMaterial',
             as: :temperable
    has_many :tempering_materials,
             -> { select 'canonical_materials.*, canonical_temperables_tempering_materials.quantity as quantity_needed' },
             through: :canonical_temperables_tempering_materials,
             source: :material

    has_many :armors,
             inverse_of: :canonical_armor,
             dependent: :nullify,
             foreign_key: 'canonical_armor_id',
             class_name: '::Armor'

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :weight,
              presence: true,
              inclusion: {
                in: ARMOR_WEIGHTS,
                message: 'must be "light armor" or "heavy armor"',
              }
    validates :body_slot,
              presence: true,
              inclusion: {
                in: %w[head body hands feet hair shield],
                message: 'must be "head", "body", "hands", "feet", "hair", or "shield"',
              }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :purchasable, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :enchantable, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :leveled, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :unique_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :rare_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :quest_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }

    validate :verify_all_smithing_perks_valid
    validate :validate_unique_item_also_rare, if: -> { unique_item == true }

    before_validation :upcase_item_code, if: -> { item_code_changed? }

    def self.unique_identifier
      :item_code
    end

    private

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
