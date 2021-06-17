# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    sequence(:uid) { |n| "foo#{n}@example.com" }
    sequence(:email) { |n| "foo#{n}@example.com" }
    name { 'Jane Doe' }
  end
end
