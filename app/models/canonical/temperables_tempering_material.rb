# frozen_string_literal: true

module Canonical
  class TemperablesTemperingMaterial < ApplicationRecord
    self.table_name = 'canonical_temperables_tempering_materials'

    belongs_to :temperable, polymorphic: true
    belongs_to :material, class_name: 'Canonical::RawMaterial'

    validates :material_id,
              uniqueness: {
                scope: %i[temperable_id temperable_type],
                message: 'must form a unique combination with temperable item',
              }
    validates :quantity, numericality: { greater_than: 0, only_integer: true }
  end
end
