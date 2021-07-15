# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list do
    game

    sequence(:title) { |n| "Shopping List #{n}" }

    factory :aggregate_shopping_list do
      aggregate { true }

      title { 'All Items' }
      aggregate_list_id { nil }
    end

    factory :shopping_list_with_list_items do
      transient do
        list_item_count { 2 }
      end

      after(:create) do |list, evaluator|
        create_list(:shopping_list_item, evaluator.list_item_count, list: list)
      end
    end
  end
end
