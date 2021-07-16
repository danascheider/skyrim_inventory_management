
# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    sequence(:uid) { |n| "foo#{n}@example.com" }
    sequence(:email) { |n| "foo#{n}@example.com" }
    name { 'Jane Doe' }

    factory :user_with_games do
      transient do
        game_count { 2 }
      end

      after(:create) do |user, evaluator|
        create_list(:game, evaluator.game_count, user: user)
      end
    end
  end
end
