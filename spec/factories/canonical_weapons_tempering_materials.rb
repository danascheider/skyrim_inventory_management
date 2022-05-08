# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_weapons_tempering_material do
    canonical_weapon
    canonical_material

    quantity { 1 }
  end
end
