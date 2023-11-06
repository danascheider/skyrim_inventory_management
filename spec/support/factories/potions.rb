# frozen_string_literal: true

FactoryBot.define do
  factory :potion do
    game

    name { 'My Potion' }

    trait :with_matching_canonical do
      association :canonical_potion, factory: %i[canonical_potion with_association]

      name { canonical_potion.name }
    end
  end
end
