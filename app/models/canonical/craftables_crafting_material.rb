# frozen_string_literal: true

module Canonical
  class CraftablesCraftingMaterial < ApplicationRecord
    self.table_name = 'canonical_craftables_crafting_materials'

    belongs_to :craftable, polymorphic: true
    belongs_to :material, class_name: 'Canonical::Material'

    # rubocop:disable Rails/UniqueValidationWithoutIndex
    validates :material_id, uniqueness: { scope: %i[craftable_id craftable_type], message: 'must form a unique combination with craftable item' }
    # rubocop:enable Rails/UniqueValidationWithoutIndex
    validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  end
end
