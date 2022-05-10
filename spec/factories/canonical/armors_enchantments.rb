# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_armors_enchantment, class: Canonical::ArmorsEnchantment do
    association :armor, factory: :canonical_armor
    enchantment
  end
end
