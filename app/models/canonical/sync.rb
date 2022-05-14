# frozen_string_literal: true

module Canonical
  module Sync
    class PrerequisiteNotMetError < StandardError; end

    SYNCERS = {
                alchemical_property: Canonical::Sync::AlchemicalProperties,
                armor:               Canonical::Sync::Armor,
                clothing:            Canonical::Sync::ClothingItems,
                enchantment:         Canonical::Sync::Enchantments,
                ingredient:          Canonical::Sync::Ingredients,
                jewelry:             Canonical::Sync::JewelryItems,
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
