# frozen_string_literal: true

class CanonicalWeapon < ApplicationRecord
  VALID_CATEGORIES   = %w[one-handed two-handed archery arrow].freeze
  VALID_WEAPON_TYPES = [
                         'battleaxe',
                         'dagger',
                         'greatsword',
                         'mace',
                         'sword',
                         'war axe',
                         'warhammer',
                         'bow',
                         'crossbow',
                         'arrow',
                         'bolt',
                       ].freeze

  VALID_COMBINATIONS = {
                         'one-handed' => [
                                           'dagger',
                                           'mace',
                                           'sword',
                                           'war axe',
                                         ],
                         'two-handed' => %w[
                                           battleaxe
                                           greatsword
                                           warhammer
                                         ],
                         'archery'    => %w[
                                           bow
                                           crossbow
                                         ],
                         'arrow'      => %w[
                                           arrow
                                           bolt
                                         ],
                       }.freeze

  VALID_SMITHING_PERKS = [
                           'Steel Smithing',
                           'Elven Smithing',
                           'Advanced Armors',
                           'Glass Smithing',
                           'Dragon Armor',
                           'Arcane Blacksmith',
                           'Dwarven Smithing',
                           'Orcish Smithing',
                           'Ebony Smithing',
                           'Daedric Smithing',
                         ].freeze

  validates :name, presence: true
  validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
  validates :category,
            presence:  true,
            inclusion: {
                         in:      VALID_CATEGORIES,
                         message: 'must be "one-handed", "two-handed", "archery", or "arrow"',
                       }
  validates :weapon_type,
            presence:  true,
            inclusion: {
                         in:      VALID_WEAPON_TYPES,
                         message: 'must be a valid type of weapon that occurs in Skyrim',
                       }
  validates :base_damage, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :verify_category_type_combination
  validate :verify_all_smithing_perks_valid

  private

  def verify_category_type_combination
    errors.add(:weapon_type, "is not included in category \"#{category}\"") unless VALID_COMBINATIONS[category]&.include?(weapon_type)
  end

  def verify_all_smithing_perks_valid
    smithing_perks.each do |perk|
      errors.add(:smithing_perks, "\"#{perk}\" is not a valid smithing perk") unless VALID_SMITHING_PERKS.include?(perk)
    end
  end
end
