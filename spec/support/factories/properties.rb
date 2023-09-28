# frozen_string_literal: true

FactoryBot.define do
  factory :property do
    name { 'My House' }

    trait :with_matching_canonical do
      association :canonical_property, factory: :canonical_property

      name { canonical_property.name }
    end
  end
end
