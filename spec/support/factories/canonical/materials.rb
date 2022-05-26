# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_material, class: Canonical::Material do
    name                 { 'iron ingot' }
    sequence(:item_code) {|n| "xxx000#{n}" }
    unit_weight          { 2.4 }
  end
end
