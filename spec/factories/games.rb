# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    user
    
    sequence(:name) { |n| "My Game #{n}" }
  end
end
