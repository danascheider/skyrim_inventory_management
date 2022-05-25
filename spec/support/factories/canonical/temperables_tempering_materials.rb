# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_temperables_tempering_material, class: Canonical::TemperablesTemperingMaterial do
    association :material, factory: :canonical_material
    quantity { 1 }

    trait :for_armor do
      association :temperable, factory: :canonical_armor
    end

    trait :for_weapon do
      association :temperable, factory: :canonical_weapon
    end
  end
end
