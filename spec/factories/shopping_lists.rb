# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list do
    user

    sequence(:title) { |n| "My List #{n}" }

    factory :master_shopping_list do
      master { true }

      title { 'Master' }
      master_list_id { nil }

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
