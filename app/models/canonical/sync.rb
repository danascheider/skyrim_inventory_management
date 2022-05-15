# frozen_string_literal: true

module Canonical
  module Sync
    class PrerequisiteNotMetError < StandardError; end

    SYNCERS = {
                # Syncers that are prerequisites for other syncers
                alchemical_property: Canonical::Sync::AlchemicalProperties,
                enchantment:         Canonical::Sync::Enchantments,
                material:            Canonical::Sync::Materials,
                power:               Canonical::Sync::Powers,
                # Syncers that are not prerequisites for other syncers
                armor:               Canonical::Sync::Armor,
                clothing:            Canonical::Sync::ClothingItems,
                ingredient:          Canonical::Sync::Ingredients,
                jewelry:             Canonical::Sync::JewelryItems,
                property:            Canonical::Sync::Properties,
                spell:               Canonical::Sync::Spells,
                weapon:              Canonical::Sync::Weapons,
              }.freeze

    module_function

    def perform(model = :all, preserve_existing_records = false)
      if model == :all
        SYNCERS.each_value {|syncer| syncer.perform(preserve_existing_records) }
      else
        SYNCERS[model].perform(preserve_existing_records)
      end
    end
  end
end
