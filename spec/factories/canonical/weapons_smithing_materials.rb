# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_weapons_smithing_material, class: Canonical::WeaponsSmithingMaterial do
    association :weapon, factory: :canonical_weapon
    association :material, factory: :canonical_material

    quantity { 2 }
  end
end
