# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_ingredient, class: Canonical::Ingredient do
    name                 { 'Blue Mountain Flower' }
    sequence(:item_code) {|n| "xx123xx#{n}" }
    unit_weight          { 0.5 }
  end
end
