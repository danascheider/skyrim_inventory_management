# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_armors_enchantment do
    association :canonical_armor, factory: :canonical_armor
    enchantment
  end
end
