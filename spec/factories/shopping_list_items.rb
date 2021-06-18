# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list_item do
    shopping_list

    description { 'Necklace' }
    quantity { 1 }
  end
end
