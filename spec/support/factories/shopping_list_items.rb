# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list_item do
    association :list, factory: :shopping_list

    sequence(:description) {|n| "Item #{n}" }
    quantity { 1 }
  end
end
