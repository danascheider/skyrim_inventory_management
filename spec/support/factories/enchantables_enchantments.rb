# frozen_string_literal: true

FactoryBot.define do
  factory :enchantables_enchantment do
    enchantment

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
  end
end
