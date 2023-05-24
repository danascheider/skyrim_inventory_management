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
  end
end
