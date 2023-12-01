# frozen_string_literal: true

FactoryBot.define do
  factory :wish_list_item do
    association :list, factory: :wish_list

    sequence(:description) {|n| "Item #{n}" }
    quantity { 1 }
  end
end
