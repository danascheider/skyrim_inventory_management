# frozen_string_literal: true

class CanonicalArmor < ApplicationRecord
  has_many :canonical_armors_enchantments, dependent: :destroy
  has_many :enchantments, through: :canonical_armors_enchantments

  has_many :canonical_armors_smithing_materials, dependent: :destroy
  has_many :smithing_materials, through: :canonical_armors_smithing_materials, source: :canonical_materials

  has_many :canonical_armors_tempering_materials, dependent: :destroy
  has_many :tempering_materials, through: :canonical_armors_tempering_materials, source: :canonical_materials

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
