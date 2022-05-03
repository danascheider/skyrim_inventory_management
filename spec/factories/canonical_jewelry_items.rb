# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_jewelry_item do
    name                 { 'Gold Diamond Ring' }
    sequence(:item_code) {|n| "xxx123#{n}" }
    jewelry_type         { 'ring' }
    unit_weight          { 37.0 }
    quest_item           { false }
  end
end
