# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    user
    
    sequence(:name) { |n| "My Game #{n}" }

    factory :game_with_shopping_lists do
      transient do
        shopping_list_count { 2 }
      end

      after(:create) do |game, evaluator|
        create(:aggregate_shopping_list, game: game)
        create_list(:shopping_list, evaluator.shopping_list_count, game: game)
      end
    end
  end
end
