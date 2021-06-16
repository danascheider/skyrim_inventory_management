# frozen_string_literal: true

class Property < ApplicationRecord
  OWNABLE_PROPERTIES = [
    "Arch-Mage's Quarters",
    'Breezehome',
    'Heljarchen Hall',
    'Hjerim',
    'Honeyside',
    'Lakeview Manor',
    'Proudspire Manor',
    'Severin Manor'
    'Vlindrel Hall',
    'Windstad Manor'
  ].freeze

  belongs_to :user

  validates :name, presence: true, inclusion: { in: OWNABLE_PROPERTIES }
end
