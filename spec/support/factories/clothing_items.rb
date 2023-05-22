# frozen_string_literal: true

FactoryBot.define do
  factory :clothing_item do
    game

    name { 'Fine Clothes' }

    trait :with_enchantments do
      after(:create) do |item|
        create_list(:enchantables_enchantment, 2, enchantable: item)
      end
    end
  end
end
