# frozen_string_literal: true

require 'skyrim'

class Property < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_property, class_name: 'Canonical::Property'

  has_many :shopping_lists, dependent: nil
  has_many :inventory_lists, dependent: nil

  validate :ensure_max, on: :create, if: :count_is_max

  validates :canonical_property, uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :name,
            presence: true,
            inclusion: { in: Canonical::Property::VALID_NAMES, message: "must be an ownable property in Skyrim, or the Arch-Mage's Quarters" },
            uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :hold,
            presence: true,
            inclusion: { in: Skyrim::HOLDS, message: 'must be one of the nine Skyrim holds, or Solstheim' },
            uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :city,
            inclusion: { in: Canonical::Property::VALID_CITIES, message: 'must be a Skyrim city in which an ownable property is located', allow_blank: true },
            uniqueness: { scope: :game_id, message: 'must be unique per game if present', allow_nil: true }

  validate :ensure_alchemy_lab_available, if: -> { has_alchemy_lab == true && canonical_property&.alchemy_lab_available == false }
  validate :ensure_arcane_enchanter_available, if: -> { has_arcane_enchanter == true && canonical_property&.arcane_enchanter_available == false }
  validate :ensure_forge_available, if: -> { has_forge == true && canonical_property&.forge_available == false }
  validate :ensure_enchanters_tower_available, if: -> { has_enchanters_tower == true && canonical_property&.enchanters_tower_available == false }
  validate :ensure_apiary_available, if: -> { has_apiary == true && canonical_property&.apiary_available == false }
  validate :ensure_grain_mill_available, if: -> { has_grain_mill == true && canonical_property&.grain_mill_available == false }
  validate :ensure_fish_hatchery_available, if: -> { has_fish_hatchery == true && canonical_property&.fish_hatchery_available == false }

  validate :ensure_matches_canonical_property

  validates_with HomesteadValidator

  before_validation :set_canonical_model
  before_validation :set_values_from_canonical

  DOES_NOT_MATCH = "doesn't match any ownable property that exists in Skyrim"

  private

  def set_canonical_model
    self.canonical_property ||= Canonical::Property.find_by('name ILIKE ?', name)
  end

  def set_values_from_canonical
    return if canonical_property.nil?

    self.name = canonical_property.name
    self.city = canonical_property.city
    self.hold = canonical_property.hold
  end

  def ensure_max
    Rails.logger.error "Cannot create property \"#{name}\" in hold \"#{hold}\": this game already has #{Canonical::Property::TOTAL_PROPERTY_COUNT} properties"
    errors.add(:game, 'already has max number of ownable properties')
  end

  def count_is_max
    game.present? && game.properties.count == Canonical::Property::TOTAL_PROPERTY_COUNT
  end

  def ensure_alchemy_lab_available
    errors.add(:has_alchemy_lab, 'cannot be true because this property cannot have an alchemy lab in Skyrim')
  end

  def ensure_arcane_enchanter_available
    errors.add(:has_arcane_enchanter, 'cannot be true because this property cannot have an arcane enchanter in Skyrim')
  end

  def ensure_forge_available
    errors.add(:has_forge, 'cannot be true because this property cannot have a forge in Skyrim')
  end

  def ensure_apiary_available
    errors.add(:has_apiary, 'cannot be true because this property cannot have an apiary in Skyrim')
  end

  def ensure_grain_mill_available
    errors.add(:has_grain_mill, 'cannot be true because this property cannot have a grain mill in Skyrim')
  end

  def ensure_fish_hatchery_available
    errors.add(:has_fish_hatchery, 'cannot be true because this property cannot have a fish hatchery in Skyrim')
  end

  def ensure_matches_canonical_property
    errors.add(:base, DOES_NOT_MATCH) if canonical_property.blank?
  end
end
