# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_ingredient, class: Canonical::Ingredient do
    name { 'Blue Mountain Flower' }
    sequence(:item_code) {|n| "xx123xx#{n}" }
    ingredient_type { 'common' }
    unit_weight { 0.5 }
    purchasable { true }
    purchase_requires_perk { false }
    unique_item { false }
    rare_item { false }

    trait :with_alchemical_properties do
      after(:create) do |ingredient, _evaluator|
        4.times do |n|
          create(:canonical_ingredients_alchemical_property, ingredient:, priority: n + 1)
        end
      end
    end
  end
end
