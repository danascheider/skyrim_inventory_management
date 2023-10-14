# frozen_string_literal: true

FactoryBot.define do
  factory :jewelry_item do
    game
    name { 'Gold Diamond Ring' }

    trait :with_matching_canonical do
      association :canonical_jewelry_item
    end
  end
end
