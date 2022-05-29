# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_jewelry_item, class: Canonical::JewelryItem do
    name                 { 'Gold Diamond Ring' }
    sequence(:item_code) {|n| "xxx123#{n}" }
    jewelry_type         { 'ring' }
    unit_weight          { 37.0 }
    purchasable          { true }
    unique_item          { false }
    rare_item            { false }
    quest_item           { false }
  end
end
