# frozen_string_literal: true

FactoryBot.define do
  factory :property do
    game

    name { 'Lakeview Manor' }

    trait :with_matching_canonical do
      association :canonical_property
    end
  end
end
