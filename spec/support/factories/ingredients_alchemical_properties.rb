# frozen_string_literal: true

FactoryBot.define do
  factory :ingredients_alchemical_property do
    ingredient
    alchemical_property

    sequence(:priority) {|n| (n % 4) + 1 }
  end
end
