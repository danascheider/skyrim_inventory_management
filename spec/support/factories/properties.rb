# frozen_string_literal: true

FactoryBot.define do
  factory :property do
    trait :with_canonical do
      canonical_property
    end
  end
end
