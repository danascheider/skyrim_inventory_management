# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_weapons_enchantment, class: Canonical::WeaponsEnchantment do
    association :weapon, factory: :canonical_weapon
    enchantment

    strength { 15 }
  end
end