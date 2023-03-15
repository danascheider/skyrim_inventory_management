# frozen_string_literal: true

module Canonical
  class Potion < ApplicationRecord
    self.table_name = 'canonical_potions'

    BOOLEAN_VALUES = [true, false].freeze
    BOOLEAN_VALIDATION_MESSAGE = 'must be true or false'
    VALID_POTION_TYPES = %w[potion poison].freeze

    has_many :canonical_potions_alchemical_properties,
             dependent: :destroy,
             class_name: 'Canonical::PotionsAlchemicalProperty',
             inverse_of: :potion
    has_many :alchemical_properties, through: :canonical_potions_alchemical_properties

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :potion_type, presence: true, inclusion: { in: VALID_POTION_TYPES, message: 'must be "potion" or "poison"' }

    validate :validate_boolean_values
    validate :validate_unique_item_also_rare, if: -> { unique_item == true }

    before_validation :upcase_item_code, if: -> { item_code_changed? }

    def self.unique_identifier
      :item_code
    end

    private

    def validate_boolean_values
      errors.add(:purchasable, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(purchasable)
      errors.add(:unique_item, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(unique_item)
      errors.add(:rare_item, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(rare_item)
      errors.add(:quest_item, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(quest_item)
    end

    def validate_unique_item_also_rare
      errors.add(:rare_item, 'must be true if item is unique') unless rare_item == true
    end

    def upcase_item_code
      item_code.upcase!
    end
  end
end
