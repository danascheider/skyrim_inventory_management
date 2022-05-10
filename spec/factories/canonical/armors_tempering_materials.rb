# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_armors_tempering_material, class: Canonical::ArmorsTemperingMaterial do
    association :armor, factory: :canonical_armor
    association :material, factory: :canonical_material
    quantity { 1 }
  end
end
