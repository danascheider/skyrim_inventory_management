# frozen_string_literal: true

FactoryBot.define do
  factory :misc_item do
    game

    name { "Wylandria's Soul Gem" }

    trait :with_matching_canonical do
      association :canonical_misc_item, factory: :canonical_misc_item

      name { canonical_misc_item.name }
    end
  end
end
