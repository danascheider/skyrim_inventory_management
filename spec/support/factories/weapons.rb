# frozen_string_literal: true

FactoryBot.define do
  factory :weapon do
    game

    name { 'Dwarven War Axe' }

    trait :with_matching_canonical do
      association :canonical_weapon,
                  factory: :canonical_weapon,
                  strategy: :create

      name { canonical_weapon.name }
    end

    trait :with_enchanted_canonical do
      association :canonical_weapon,
                  factory: %i[canonical_weapon with_enchantments],
                  strategy: :create

      name { canonical_weapon.name }
    end
  end
end
