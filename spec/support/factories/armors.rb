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

    trait :with_matching_canonical do
      association :canonical_armor, strategy: :create
    end
  end
end
