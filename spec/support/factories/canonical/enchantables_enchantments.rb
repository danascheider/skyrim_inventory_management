# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_enchantables_enchantment, class: Canonical::EnchantablesEnchantment do
    enchantment

    trait :for_armor do
      association :enchantable, factory: :canonical_armor
    end

    trait :for_clothing do
      association :enchantable, factory: :canonical_clothing_item
    end

    trait :for_jewelry do
      association :enchantable, factory: :canonical_jewelry_item
    end

    trait :for_weapon do
      association :enchantable, factory: :canonical_weapon
    end
  end
end
