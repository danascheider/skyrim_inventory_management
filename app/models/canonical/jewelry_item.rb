# frozen_string_literal: true

module Canonical
  class JewelryItem < ApplicationRecord
    self.table_name = 'canonical_jewelry_items'

    BOOLEAN_VALUES = [true, false].freeze
    BOOLEAN_VALIDATION_MESSAGE = 'must be true or false'
    JEWELRY_TYPES = %w[ring circlet amulet].freeze
    JEWELRY_TYPE_VALIDATION_MESSAGE = 'must be "ring", "circlet", or "amulet"'

    has_many :enchantables_enchantments,
             dependent: :destroy,
             as: :enchantable
    has_many :enchantments,
             -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
             through: :enchantables_enchantments

    has_many :canonical_craftables_crafting_materials,
             dependent: :destroy,
             class_name: 'Canonical::CraftablesCraftingMaterial',
             as: :craftable
    has_many :crafting_materials,
             -> { select 'canonical_raw_materials.*, canonical_craftables_crafting_materials.quantity as quantity_needed' },
             through: :canonical_craftables_crafting_materials,
             source: :material

    has_many :jewelry_items,
             inverse_of: :canonical_jewelry_item,
             dependent: :nullify,
             foreign_key: 'canonical_jewelry_item_id',
             class_name: '::JewelryItem'

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :jewelry_type,
              presence: true,
              inclusion: { in: JEWELRY_TYPES, message: JEWELRY_TYPE_VALIDATION_MESSAGE }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :purchasable, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :unique_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :rare_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :quest_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :enchantable, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }

    validate :validate_unique_item_also_rare, if: -> { unique_item == true }

    before_validation :upcase_item_code, if: -> { item_code_changed? }

    def self.unique_identifier
      :item_code
    end

    private

    def validate_unique_item_also_rare
      errors.add(:rare_item, 'must be true if item is unique') unless rare_item == true
    end

    def upcase_item_code
      item_code.upcase!
    end
  end
end
