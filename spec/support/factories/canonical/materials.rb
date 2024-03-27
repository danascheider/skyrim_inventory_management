# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_material, class: Canonical::Material do
    association :source_material, factory: :canonical_raw_material

    quantity { 1 }

    trait :with_craftable do
      association :craftable, factory: %i[canonical_weapon]
    end

    trait :with_temperable do
      association :temperable, factory: %i[canonical_armor]
    end
  end
end
