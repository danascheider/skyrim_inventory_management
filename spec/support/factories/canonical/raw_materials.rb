# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_raw_material, class: Canonical::RawMaterial do
    name { 'iron ingot' }
    sequence(:item_code) {|n| "xxx000#{n}" }
    unit_weight { 2.4 }
    add_on { 'base' }
  end
end
