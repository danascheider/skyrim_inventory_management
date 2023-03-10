# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_book, class: Canonical::Book do
    title { 'My Book' }
    sequence(:item_code) {|n| "123xxx#{n}" }
    unit_weight { 1.0 }
    book_type { 'lore book' }
    purchasable { true }
    unique_item { false }
    rare_item { false }
    solstheim_only { false }
    quest_item { false }

    factory :canonical_recipe do
      book_type { 'recipe' }
    end
  end
end
