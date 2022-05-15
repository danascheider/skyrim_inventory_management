# frozen_string_literal: true

module Canonical
  class Material < ApplicationRecord
    self.table_name = 'canonical_materials'

    has_many :canonical_craftables_crafting_materials,
             dependent:  :destroy,
             class_name: 'Canonical::CraftablesCraftingMaterial',
             inverse_of: :material
    has_many :craftables, through: :canonical_craftables_crafting_materials

    has_many :canonical_temperables_tempering_materials,
             dependent:  :destroy,
             class_name: 'Canonical::TemperablesTemperingMaterial',
             inverse_of: :material
    has_many :temperables, through: :canonical_temperables_tempering_materials

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def self.unique_identifier
      :item_code
    end
  end
end
