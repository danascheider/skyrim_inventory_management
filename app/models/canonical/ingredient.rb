# frozen_string_literal: true

module Canonical
  class Ingredient < ApplicationRecord
    self.table_name = 'canonical_ingredients'

    VALID_TYPES                = %w[common uncommon rare Solstheim].freeze
    TYPE_VALIDATION_MESSAGE    = 'must be "common", "uncommon", "rare", or "Solstheim"'
    BOOLEAN_VALUES             = [true, false].freeze
    BOOLEAN_VALIDATION_MESSAGE = 'must be true or false'

    has_many :canonical_ingredients_alchemical_properties,
             dependent:  :destroy,
             class_name: 'Canonical::IngredientsAlchemicalProperty'
    has_many :alchemical_properties, through: :canonical_ingredients_alchemical_properties

    has_many :canonical_recipes_ingredients,
             dependent:  :destroy,
             class_name: 'Canonical::RecipesIngredient',
             inverse_of: :ingredient
    has_many :recipes, through: :canonical_recipes_ingredients, class_name: 'Canonical::Book', source: :recipe

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :ingredient_type, inclusion: { in: VALID_TYPES, message: TYPE_VALIDATION_MESSAGE, allow_blank: true }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :purchase_requires_perk,
              inclusion: {
                           in:      BOOLEAN_VALUES,
                           message: "#{BOOLEAN_VALIDATION_MESSAGE} if purchasable is true",
                         },
              if:        -> { purchasable == true }
    validates :unique_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :rare_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :quest_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }

    validate :validate_purchasable
    validate :validate_purchase_requires_perk
    validate :validate_unique_item_also_rare, if: -> { unique_item == true }

    def self.unique_identifier
      :item_code
    end

    private

    def validate_purchasable
      errors.add(:purchasable, BOOLEAN_VALIDATION_MESSAGE) unless BOOLEAN_VALUES.include?(purchasable)
      errors.add(:purchasable, 'must be true if ingredient_type is set') if ingredient_type && !purchasable
    end

    def validate_purchase_requires_perk
      errors.add(:purchase_requires_perk, "can't be set if purchasable is false") if purchasable == false && !purchase_requires_perk.nil?
    end

    def validate_unique_item_also_rare
      errors.add(:rare_item, 'must be true if item is unique') unless rare_item == true
    end
  end
end
