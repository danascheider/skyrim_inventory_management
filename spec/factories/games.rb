# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    user
    
    sequence(:name) { |n| "Skyrim Game #{n}" }

    factory :game_with_shopping_lists do
      transient do
        shopping_list_count { 2 }
      end

      after(:create) do |game, evaluator|
        create(:aggregate_shopping_list, game: game)
        create_list(:shopping_list, evaluator.shopping_list_count, game: game)
      end
    end

    factory :game_with_shopping_lists_and_items do
      transient do
        shopping_list_count { 2 }
      end

      after(:create) do |game, evaluator|
        aggregate_list = create(:aggregate_shopping_list, game: game)
        shopping_lists = create_list(:shopping_list_with_list_items, evaluator.shopping_list_count, game: game)

        shopping_lists.each do |list|
          list.list_items.each do |item|
            aggregate_list.add_item_from_child_list(item)
          end
        end
      end
    end
  end
end
