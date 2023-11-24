# frozen_string_literal: true

FactoryBot.define do
  factory :potions_alchemical_property do
    alchemical_property
    association :potion, factory: %i[potion with_matching_canonical]

    added_automatically { false }
    strength { 20 }
    duration { 30 }
  end
end
