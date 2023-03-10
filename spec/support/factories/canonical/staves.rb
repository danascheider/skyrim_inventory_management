# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_staff, class: 'Canonical::Staff' do
    sequence(:item_code) {|n| "XX222#{n}" }
    name { 'Staff of Chain Lightning' }
    unit_weight { 8 }
    base_damage { 0 }
    daedric { false }
    purchasable { true }
    unique_item { false }
    rare_item { false }
    quest_item { false }
    leveled { false }
  end
end
