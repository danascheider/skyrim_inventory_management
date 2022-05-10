# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_armors_smithing_material, class: Canonical::ArmorsSmithingMaterial do
    association :armor, factory_name: :canonical_armor
    association :material, factory_name: :canonical_material
    quantity { 2 }
  end
end
