# frozen_string_literal: true

FactoryBot.define do
  factory :enchantables_enchantment do
    enchantment

    added_automatically { false }

    trait :for_canonical_armor do
      association :enchantable, factory: :canonical_armor
    end

    trait :for_canonical_clothing do
      association :enchantable, factory: :canonical_clothing_item
    end

    trait :for_canonical_jewelry do
      association :enchantable, factory: :canonical_jewelry_item
    end

    trait :for_canonical_weapon do
      association :enchantable, factory: :canonical_weapon
    end

    trait :for_armor do
      association :enchantable, factory: %i[armor with_matching_canonical]
    end

    trait :for_weapon do
      association :enchantable, factory: %i[weapon with_matching_canonical]
    end

    trait :with_strength do
      strength { 20 }
    end
  end
end
