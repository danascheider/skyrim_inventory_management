# frozen_string_literal: true

class CanonicalProperty < ApplicationRecord
  TOTAL_PROPERTY_COUNT = 10

  VALID_NAMES = [
                  "Arch-Mage's Quarters",
                  'Breezehome',
                  'Heljarchen Hall',
                  'Hjerim',
                  'Honeyside',
                  'Lakeview Manor',
                  'Proudspire Manor',
                  'Severin Manor',
                  'Vlindrel Hall',
                  'Windstad Manor',
                ].freeze

  VALID_HOLDS = [
                  'Eastmarch',
                  'Falkreath',
                  'Haafingar',
                  'Hjaalmarch',
                  'Solstheim',
                  'The Pale',
                  'The Reach',
                  'The Rift',
                  'Whiterun',
                  'Winterhold',
                ].freeze

  validate :ensure_max, if: :count_is_max

  validates :name,
            presence:   true,
            inclusion:  { in: VALID_NAMES, message: "must be an ownable property in Skyrim, or the Arch-Mage's Quarters" },
            uniqueness: true

  validates :hold,
            presence:   true,
            inclusion:  { in: VALID_HOLDS, message: 'must be one of the nine Skyrim holds, or Solstheim' },
            uniqueness: true

  private

  def ensure_max
    Rails.logger.error "Cannot create canonical property \"#{name}\" in hold \"#{hold}\": there are already #{TOTAL_PROPERTY_COUNT} canonical properties"
    errors.add(:base, "cannot create a new canonical property as there are already #{TOTAL_PROPERTY_COUNT}")
  end

  def count_is_max
    CanonicalProperty.count == TOTAL_PROPERTY_COUNT
  end
end
