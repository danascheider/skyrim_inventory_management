# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_clothing_item do
    name                 { 'Fine Clothes' }
    sequence(:item_code) {|n| "123xxx#{n}" }
    unit_weight          { 9.9 }
    body_slot            { 'body' }
    quest_item           { false }
  end
end
