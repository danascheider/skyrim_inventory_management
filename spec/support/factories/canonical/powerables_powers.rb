# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_powerables_power, class: Canonical::PowerablesPower do
    power

    trait :for_weapon do
      association :powerable, factory: :canonical_weapon
    end

    trait :for_staff do
      association :powerable, factory: :canonical_staff
    end
  end
end
