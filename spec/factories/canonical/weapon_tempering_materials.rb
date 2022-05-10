# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_weapons_tempering_material, class: Canonical::WeaponsTemperingMaterial do
    association :weapon, factory: :canonical_weapon
    association :material, factory: :canonical_material

    quantity { 1 }
  end
end
