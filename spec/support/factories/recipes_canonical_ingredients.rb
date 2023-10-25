# frozen_string_literal: true

FactoryBot.define do
  factory :recipes_canonical_ingredient do
    association :ingredient, factory: :canonical_ingredient

    trait :for_canonical_recipe do
      association :recipe, factory: :canonical_recipe
    end

    trait :for_non_canonical_recipe do
      association :recipe, factory: %i[book with_matching_canonical]
    end
  end
end
