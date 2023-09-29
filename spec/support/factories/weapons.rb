# frozen_string_literal: true

FactoryBot.define do
  factory :weapon do
    game

    name { 'Ancient Nord War Axe of Cold' }

    trait :with_matching_canonical do
      association :canonical_weapon, factory: :canonical_weapon

      name { canonical_weapon.name }
    end
  end
end
