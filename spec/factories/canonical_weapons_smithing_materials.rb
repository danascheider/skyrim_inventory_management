# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_weapons_smithing_material do
    canonical_weapon
    canonical_material

    quantity { 2 }
  end
end
