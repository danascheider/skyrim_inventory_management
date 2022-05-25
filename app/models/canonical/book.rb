# frozen_string_literal: true

module Canonical
  class Book < ApplicationRecord
    self.table_name = 'canonical_books'

    BOOLEAN_VALUES             = [true, false].freeze
    BOOLEAN_VALIDATION_MESSAGE = 'must be true or false'

    BOOK_TYPES = [
                   'black book',
                   'document',
                   'elder scroll',
                   'journal',
                   'letter',
                   'lore book',
                   'quest book',
                   'recipe',
                   'skill book',
                   'treasure map',
                 ].freeze

    SKILLS = [
               'Alchemy',
               'Alteration',
               'Archery',
               'Block',
               'Conjuration',
               'Destruction',
               'Enchanting',
               'Heavy Armor',
               'Illusion',
               'Light Armor',
               'Lockpicking',
               'One-Handed',
               'Pickpocket',
               'Restoration',
               'Smithing',
               'Sneak',
               'Speech',
               'Two-Handed',
             ].freeze

    has_many :canonical_recipes_ingredients,
             dependent:   :destroy,
             class_name:  'Canonical::RecipesIngredient',
             inverse_of:  :recipe,
             foreign_key: :recipe_id
    has_many :canonical_ingredients, through: :canonical_recipes_ingredients, class_name: 'Canonical::Ingredient', source: :ingredient

    validates :title, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :book_type, inclusion: { in: BOOK_TYPES, message: 'must be a book type that exists in Skyrim' }
    validates :skill_name, inclusion: { in: SKILLS, message: 'must be a skill that exists in Skyrim', allow_blank: true }
    validates :purchasable, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :unique_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :rare_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :solstheim_only, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }
    validates :quest_item, inclusion: { in: BOOLEAN_VALUES, message: BOOLEAN_VALIDATION_MESSAGE }

    validate :validate_skill_name_presence
    validate :verify_unique_item_rare, if: -> { unique_item == true }

    def self.unique_identifier
      :item_code
    end

    private

    def validate_skill_name_presence
      if book_type == 'skill book'
        errors.add(:skill_name, "can't be blank for skill books") if skill_name.blank?
      elsif skill_name.present?
        errors.add(:skill_name, 'can only be defined for skill books')
      end
    end

    def verify_unique_item_rare
      errors.add(:rare_item, 'must be true if item is unique') unless rare_item == true
    end
  end
end
