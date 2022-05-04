# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_armors_smithing_material do
    canonical_armor
    canonical_material
    quantity { 2 }
  end
end
