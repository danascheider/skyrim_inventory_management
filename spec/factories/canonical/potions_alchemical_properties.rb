# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_potions_alchemical_property, class: Canonical::PotionsAlchemicalProperty do
    alchemical_property
    association(:potion, factory: :canonical_potion)
    strength { 20 }
    duration { 30 }
  end
end
