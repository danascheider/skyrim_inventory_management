# frozen_string_literal: true

FactoryBot.define do
  factory :ingredient do
    game

    name { 'Blue Mountain Flower' }

    trait :with_alchemical_properties do
      after(:create) do |ingredient|
        4.times do |n|
          create(:ingredients_alchemical_property, ingredient:, priority: n + 1)
        end
      end
    end

    factory :ingredient_with_matching_canonical do
      canonical_ingredient

      trait :with_associations do
        association :canonical_ingredient, factory: %i[canonical_ingredient with_alchemical_properties]
      end

      trait :with_associations_and_properties do
        association :canonical_ingredient, factory: %i[canonical_ingredient with_alchemical_properties]

        after(:create) do |model|
          model.canonical_ingredient.canonical_ingredients_alchemical_properties.each do |join_model|
            create(
              :ingredients_alchemical_property,
              ingredient: model,
              **join_model.attributes.except('ingredient_id', 'created_at', 'updated_at'),
            )
          end
        end
      end
    end
  end
end
