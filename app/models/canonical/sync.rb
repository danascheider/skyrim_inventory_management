# frozen_string_literal: true

module Canonical
  module Sync
    SYNCERS = {
                alchemical_property: Canonical::Sync::AlchemicalProperties,
                enchantment:         Canonical::Sync::Enchantments,
                spell:               Canonical::Sync::Spells,
                property:            Canonical::Sync::Properties,
              }.freeze

    module_function

    def perform(model = :all, preserve_existing_records = false)
      SYNCERS[model].perform(preserve_existing_records)
    end
  end
end
