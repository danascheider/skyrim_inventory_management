# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_armors_tempering_material, class: Canonical::ArmorsTemperingMaterial do
    canonical_armor
    canonical_material
    quantity { 1 }
  end
end
