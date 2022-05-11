# frozen_string_literal: true

module Canonical
  module Sync
    SYNCERS = {
                alchemical_property: Canonical::Sync::AlchemicalProperties,
                enchantment:         Canonical::Sync::Enchantments,
                material:            Canonical::Sync::Materials,
                property:            Canonical::Sync::Properties,
                spell:               Canonical::Sync::Spells,
              }.freeze

    module_function

    def perform(model = :all, preserve_existing_records = false)
      SYNCERS[model].perform(preserve_existing_records)
    end
  end
end
