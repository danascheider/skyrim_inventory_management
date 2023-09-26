# frozen_string_literal: true

FactoryBot.define do
  factory :staff do
    game

    name { 'My Cool Staff' }
    unit_weight { 8 }

    trait :with_matching_canonical do
      association :canonical_staff, factory: :canonical_staff

      name { canonical_staff.name }
    end
  end
end
