# frozen_string_literal: true

module Canonical
  class Armor < ApplicationRecord
    self.table_name = 'canonical_armors'

    has_many :canonical_enchantables_enchantments,
             dependent:  :destroy,
             class_name: 'Canonical::EnchantablesEnchantment',
             as:         :enchantable
    has_many :enchantments,
             -> { select 'enchantments.*, canonical_enchantables_enchantments.strength as strength' },
             through: :canonical_enchantables_enchantments

    has_many :canonical_craftables_crafting_materials,
             dependent:  :destroy,
             class_name: 'Canonical::CraftablesCraftingMaterial',
             as:         :craftable
    has_many :crafting_materials,
             -> { select 'canonical_materials.*, canonical_craftables_crafting_materials.quantity as quantity_needed' },
             through: :canonical_craftables_crafting_materials,
             source:  :material

    has_many :canonical_temperables_tempering_materials,
             dependent:  :destroy,
             class_name: 'Canonical::TemperablesTemperingMaterial',
             as:         :temperable
    has_many :tempering_materials,
             -> { select 'canonical_materials.*, canonical_temperables_tempering_materials.quantity as quantity_needed' },
             through: :canonical_temperables_tempering_materials,
             source:  :material

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :weight,
              presence:  true,
              inclusion: {
                           in:      ['light armor', 'heavy armor'],
                           message: 'must be "light armor" or "heavy armor"',
                         }
    validates :body_slot,
              presence:  true,
              inclusion: {
                           in:      %w[head body hands feet hair shield],
                           message: 'must be "head", "body", "hands", "feet", "hair", or "shield"',
                         }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def self.unique_identifier
      :item_code
    end
  end
end
