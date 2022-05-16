# frozen_string_literal: true

module Canonical
  class StavesSpell < ApplicationRecord
    self.table_name = 'canonical_staves_spells'

    belongs_to :staff, class_name: 'Canonical::Staff'
    belongs_to :spell

    validates :strength, numericality: { greater_than: 0, allow_blank: true }
    validates :staff_id, uniqueness: { scope: :spell_id, message: 'must form a unique combination with spell' }
  end
end
