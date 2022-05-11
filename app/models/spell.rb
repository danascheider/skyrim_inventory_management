# frozen_string_literal: true

class Spell < ApplicationRecord
  SCHOOLS = %w[
              Alteration
              Conjuration
              Destruction
              Illusion
              Restoration
            ].freeze

  LEVELS = %w[
             Novice
             Apprentice
             Adept
             Expert
             Master
           ].freeze

  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :school, presence: true, inclusion: { in: SCHOOLS, message: 'must be a valid school of magic' }
  validates :level, presence: true, inclusion: { in: LEVELS, message: 'must be "Novice", "Apprentice", "Adept", "Expert", or "Master"' }
  validates :strength_unit, inclusion: { in: %w[point percentage], message: 'must be "point" or "percentage"', allow_blank: true }
  validates :description, presence: true
  validate :strength_and_strength_unit_both_or_neither_present

  def self.unique_identifier
    :name
  end

  private

  def strength_and_strength_unit_both_or_neither_present
    if strength.present? && strength_unit.blank?
      errors.add(:strength_unit, 'must be present if strength is given')
    elsif strength_unit.present? && strength.blank?
      errors.add(:strength, 'must be present if strength unit is given')
    end
  end
end
