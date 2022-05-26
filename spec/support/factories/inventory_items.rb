# frozen_string_literal: true

FactoryBot.define do
  factory :inventory_item do
    association :list, factory: :inventory_list

    sequence(:description) {|n| "Item #{n}" }
    quantity               { 1 }
  end
end
