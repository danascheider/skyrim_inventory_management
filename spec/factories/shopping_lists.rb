# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list do
    user

    sequence(:title) { |n| "My List #{n}" }

    factory :master_shopping_list do
      master { true }

      title { 'Master' }
    end
  end
end
