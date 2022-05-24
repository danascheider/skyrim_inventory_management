# frozen_string_literal: true

module Canonical
  class MiscItem < ApplicationRecord
    self.table_name = 'canonical_misc_items'

    BOOLEAN_VALUES = [true, false].freeze

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

    validate :validate_item_type
    validate :validate_boolean_values
    validate :verify_unique_item_also_rare

    def self.unique_identifier
      :item_code
    end

    private

    def validate_item_type
      errors.add(:item_types, 'must include at least one item type') if item_types.blank?
      errors.add(:item_types, 'can only include valid item types') if item_types&.any? {|type| VALID_ITEM_TYPES.exclude?(type) }
    end

    def validate_boolean_values
      errors.add(:purchasable, 'boolean value must be present') unless BOOLEAN_VALUES.include?(purchasable)
      errors.add(:unique_item, 'boolean value must be present') unless BOOLEAN_VALUES.include?(unique_item)
      errors.add(:rare_item, 'boolean value must be present') unless BOOLEAN_VALUES.include?(rare_item)
      errors.add(:quest_item, 'boolean value must be present') unless BOOLEAN_VALUES.include?(quest_item)
    end

    def verify_unique_item_also_rare
      errors.add(:rare_item, 'must be true if item is unique') if unique_item && !rare_item
    end
  end
end
