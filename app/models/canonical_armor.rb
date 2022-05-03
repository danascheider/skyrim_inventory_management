# frozen_string_literal: true

class CanonicalArmor < ApplicationRecord
  has_many :canonical_armors_enchantments, dependent: :destroy
  has_many :enchantments,
           -> { select 'enchantments.*, canonical_armors_enchantments.strength as enchantment_strength' },
           through: :canonical_armors_enchantments

  has_many :canonical_armors_smithing_materials, dependent: :destroy
  has_many :smithing_materials,
           -> { select 'canonical_materials.*, canonical_armors_smithing_materials.count as quantity_needed' },
           through: :canonical_armors_smithing_materials,
           source:  :canonical_material

  has_many :canonical_armors_tempering_materials, dependent: :destroy
  has_many :tempering_materials,
           -> { select 'canonical_materials.*, canonical_armors_tempering_materials.quantity as quantity_needed' },
           through: :canonical_armors_tempering_materials,
           source:  :canonical_material

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
end
