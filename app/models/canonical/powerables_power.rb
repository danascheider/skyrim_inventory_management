# frozen_string_literal: true

module Canonical
  class PowerablesPower < ApplicationRecord
    self.table_name = 'canonical_powerables_powers'

    belongs_to :powerable, polymorphic: true
    belongs_to :power

    validates :power_id, uniqueness: { scope: %i[powerable_id powerable_type], message: 'must form a unique combination with powerable item' }
  end
end
