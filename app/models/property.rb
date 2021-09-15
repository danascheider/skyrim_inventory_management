# frozen_string_literal: true

class Property < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_property

  has_many :shopping_lists, dependent: nil
  has_many :inventory_lists, dependent: nil

  validate :ensure_max, on: :create, if: :count_is_max

  validates :canonical_property, uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :name,
            presence:   true,
            inclusion:  { in: CanonicalProperty::VALID_NAMES, message: "must be an ownable property in Skyrim, or the Arch-Mage's Quarters" },
            uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :hold,
            presence:   true,
            inclusion:  { in: CanonicalProperty::VALID_HOLDS, message: 'must be one of the nine Skyrim holds, or Solstheim' },
            uniqueness: { scope: :game_id, message: 'must be unique per game' }

  validates :city,
            inclusion:  { in: CanonicalProperty::VALID_CITIES, message: 'must be a Skyrim city in which an ownable property is located', allow_blank: true },
            uniqueness: { scope: :game_id, message: 'must be unique per game if present', allow_blank: true }

  private

  def ensure_max
    Rails.logger.error "Cannot create property \"#{name}\" in hold \"#{hold}\": this game already has #{CanonicalProperty::TOTAL_PROPERTY_COUNT} properties"
    errors.add(:game, 'already has max number of ownable properties')
  end

  def count_is_max
    game.present? && game.properties.count == CanonicalProperty::TOTAL_PROPERTY_COUNT
  end
end
