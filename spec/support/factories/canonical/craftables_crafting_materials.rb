# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_craftables_crafting_material, class: Canonical::CraftablesCraftingMaterial do
    association :material, factory: :canonical_material
    quantity { 2 }

    trait :for_armor do
      association :craftable, factory: :canonical_armor
    end

    trait :for_jewelry do
      association :craftable, factory: :canonical_jewelry_item
    end

    trait :for_weapon do
      association :craftable, factory: :canonical_weapon
    end
  end
end
