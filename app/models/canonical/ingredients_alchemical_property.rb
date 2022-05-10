# frozen_string_literal: true

module Canonical
  class IngredientsAlchemicalProperty < ApplicationRecord
    self.table_name = 'canonical_ingredients_alchemical_properties'

    belongs_to :alchemical_property
    belongs_to :ingredient, class_name: 'Canonical::Ingredient'

    validates :alchemical_property_id, uniqueness: { scope: :ingredient_id, message: 'must form a unique combination with canonical ingredient' }
    # priority is allowed to be blank. Otherwise, there is no way to change the priority of properties
    # in the database if there are already 4 alchemical properties for the ingredient, because of the
    # uniqueness validations. In order to update the priority, you need to first clear priority for
    # any models that conflict, save them, and then update them again to the correct values.
    validates :priority,
              allow_blank:  true,
              uniqueness:   { scope: :ingredient_id, message: 'must be unique per ingredient' },
              numericality: {
                              greater_than_or_equal_to: 1,
                              less_than_or_equal_to:    4,
                              only_integer:             true,
                            }
    validates :strength_modifier, allow_blank: true, numericality: { greater_than: 0 }
    validates :duration_modifier, allow_blank: true, numericality: { greater_than: 0 }
    validate :ensure_max_of_four_per_ingredient, on: :create

    MAX_PER_INGREDIENT = 4

    private

    def ensure_max_of_four_per_ingredient
      errors.add(:ingredient, "already has #{MAX_PER_INGREDIENT} alchemical properties") if ingredient.alchemical_properties.count >= MAX_PER_INGREDIENT
    end
  end
end
