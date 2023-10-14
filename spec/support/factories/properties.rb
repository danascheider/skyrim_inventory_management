# frozen_string_literal: true

FactoryBot.define do
  factory :property do
    name { 'Lakeview Manor' }

    trait :with_matching_canonical do
      association :canonical_property
    end
  end
end
