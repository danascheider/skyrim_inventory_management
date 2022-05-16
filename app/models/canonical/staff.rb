# frozen_string_literal: true

module Canonical
  class Staff < ApplicationRecord
    self.table_name = 'canonical_staves'

    VALID_SCHOOLS = %w[
                      Alteration
                      Conjuration
                      Illusion
                      Destruction
                      Restoration
                    ].freeze

    has_many :canonical_powerables_powers,
             dependent:  :destroy,
             class_name: 'Canonical::PowerablesPower',
             as:         :powerable
    has_many :powers, through: :canonical_powerables_powers

    has_many :canonical_staves_spells,
             dependent:  :destroy,
             class_name: 'Canonical::StavesSpell',
             inverse_of: :staff
    has_many :spells, through: :canonical_staves_spells

    validates :name, presence: true
    validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
    validates :unit_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :base_damage,
              presence:     true,
              numericality: {
                              greater_than_or_equal_to: 0,
                              only_integer:             true,
                            }
    validates :school, inclusion: { in: VALID_SCHOOLS, message: 'must be a valid school of magic', allow_blank: true }
    validates :daedric, inclusion: { in: [true, false], message: 'boolean value must be present' }
    validates :unique_item, inclusion: { in: [true, false], message: 'boolean value must be present' }
    validates :quest_item, inclusion: { in: [true, false], message: 'boolean value must be present' }
  end
end
