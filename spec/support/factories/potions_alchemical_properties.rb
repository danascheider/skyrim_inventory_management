# frozen_string_literal: true

FactoryBot.define do
  factory :potions_alchemical_property do
    potion
    alchemical_property

    added_automatically { false }
    strength { 20 }
    duration { 30 }
  end
end
