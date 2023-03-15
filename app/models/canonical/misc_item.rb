# frozen_string_literal: true

module Canonical
  class MiscItem < ApplicationRecord
    self.table_name = 'canonical_misc_items'

    BOOLEAN_VALUES = [true, false].freeze
    BOOLEAN_VALIDATION_MESSAGE = 'must be true or false'

    VALID_ITEM_TYPES = [
      'animal part',
      'book',
      'daedric artifact',
      'dragon claw',
      'Dwemer artifact',
      'gemstone',
      'key',
      'larceny trophy',
      'map',
      'miscellaneous',
      'paragon',
      'pelt',
    ].freeze

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :item_types, presence: true

    validate :validate_item_types
    validate :validate_boolean_values
    validate :verify_unique_item_also_rare, if: -> { unique_item == true }

    before_validation :upcase_item_code, if: -> { item_code_changed? }

    def self.unique_identifier
      :item_code
    end

    private

    def validate_item_types
      errors.add(:item_types, 'must include at least one item type') if item_types.blank?
      errors.add(:item_types, 'can only include valid item types') unless item_types&.all? {|type| VALID_ITEM_TYPES.include?(type) }
    end

    def validate_boolean_values
      errors.add(:purchasable, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(purchasable)
      errors.add(:unique_item, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(unique_item)
      errors.add(:rare_item, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(rare_item)
      errors.add(:quest_item, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(quest_item)
    end

    def verify_unique_item_also_rare
      errors.add(:rare_item, 'must be true if item is unique') unless rare_item == true
    end

    def upcase_item_code
      item_code.upcase!
    end
  end
end
