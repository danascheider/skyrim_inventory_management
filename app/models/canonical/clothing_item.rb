# frozen_string_literal: true

module Canonical
  class ClothingItem < ApplicationRecord
    self.table_name = 'canonical_clothing_items'

    BODY_SLOTS = %w[head hands body feet].freeze

    has_many :enchantables_enchantments,
             dependent: :destroy,
             as: :enchantable
    has_many :enchantments,
             -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
             through: :enchantables_enchantments

    has_many :clothing_items,
             inverse_of: :canonical_clothing_item,
             dependent: :nullify,
             foreign_key: 'canonical_clothing_item_id',
             class_name: '::ClothingItem'

    validates :name, presence: true
    validates :item_code,
              presence: true,
              uniqueness: { message: 'must be unique' }
    validates :unit_weight,
              presence: true,
              numericality: { greater_than_or_equal_to: 0 }
    validates :body_slot,
              presence: true,
              inclusion: {
                in: BODY_SLOTS,
                message: 'must be "head", "hands", "body", or "feet"',
              }
    validates :purchasable,
              inclusion: {
                in: BOOLEAN_VALUES,
                message: BOOLEAN_VALIDATION_MESSAGE,
              }
    validates :unique_item,
              inclusion: {
                in: BOOLEAN_VALUES,
                message: BOOLEAN_VALIDATION_MESSAGE,
              }
    validates :rare_item,
              inclusion: {
                in: BOOLEAN_VALUES,
                message: BOOLEAN_VALIDATION_MESSAGE,
              }
    validates :quest_item,
              inclusion: {
                in: BOOLEAN_VALUES,
                message: BOOLEAN_VALIDATION_MESSAGE,
              }
    validates :enchantable,
              inclusion: {
                in: BOOLEAN_VALUES,
                message: BOOLEAN_VALIDATION_MESSAGE,
              }

    validate :validate_unique_item_also_rare, if: -> { unique_item == true }

    before_validation :upcase_item_code, if: :item_code_changed?

    # include Canonical

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
