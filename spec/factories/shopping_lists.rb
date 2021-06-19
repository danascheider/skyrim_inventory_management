# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list do
    user

    factory :master_shopping_list do
      master { true }
    end
  end
end
