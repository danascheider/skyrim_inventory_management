# frozen_string_literal: true

module Canonical
  module Sync
    class PrerequisiteNotMetError < StandardError; end

    SYNCERS = {
      # Syncers that are prerequisites for other syncers
      alchemical_property: Canonical::Sync::AlchemicalProperties,
      enchantment: Canonical::Sync::Enchantments,
      material: Canonical::Sync::RawMaterials,
      power: Canonical::Sync::Powers,
      spell: Canonical::Sync::Spells,
      ingredient: Canonical::Sync::Ingredients,
      # Syncers that are not prerequisites for other syncers
      armor: Canonical::Sync::Armor,
      book: Canonical::Sync::Books,
      clothing: Canonical::Sync::ClothingItems,
      jewelry: Canonical::Sync::JewelryItems,
      misc_item: Canonical::Sync::MiscItems,
      potion: Canonical::Sync::Potions,
      property: Canonical::Sync::Properties,
      staff: Canonical::Sync::Staves,
      weapon: Canonical::Sync::Weapons,
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
