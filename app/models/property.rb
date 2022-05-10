# frozen_string_literal: true

class Property < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_property, class_name: 'Canonical::Property'

  has_many :shopping_lists, dependent: nil
  has_many :inventory_lists, dependent: nil

  validate :ensure_max, on: :create, if: :count_is_max

  validates :canonical_property, uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :name,
            presence:   true,
            inclusion:  { in: Canonical::Property::VALID_NAMES, message: "must be an ownable property in Skyrim, or the Arch-Mage's Quarters" },
            uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :hold,
            presence:   true,
            inclusion:  { in: Canonical::Property::VALID_HOLDS, message: 'must be one of the nine Skyrim holds, or Solstheim' },
            uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :city,
            inclusion:  { in: Canonical::Property::VALID_CITIES, message: 'must be a Skyrim city in which an ownable property is located', allow_blank: true },
            uniqueness: { scope: :game_id, message: 'must be unique per game if present', allow_blank: true }

  validate :ensure_alchemy_lab_available,      if: -> { has_alchemy_lab == true && !canonical_property&.alchemy_lab_available }
  validate :ensure_arcane_enchanter_available, if: -> { has_arcane_enchanter == true && !canonical_property&.arcane_enchanter_available }
  validate :ensure_forge_available,            if: -> { has_forge == true && !canonical_property&.forge_available }
  validate :ensure_matches_canonical_property

  private

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

  def ensure_matches_canonical_property
    errors.add(:base, 'property attributes must match attributes of a property that exists in Skyrim') unless name == canonical_property&.name && hold == canonical_property&.hold && city == canonical_property&.city
  end
end
