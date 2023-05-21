# frozen_string_literal: true

FactoryBot.define do
  factory :armor do
    game

    name { 'Steel Plate Armor' }

    trait :with_enchantments do
      after(:create) do |armor|
        create_list(:enchantables_enchantment, 2, enchantable: armor)
      end
    end
  end
end
