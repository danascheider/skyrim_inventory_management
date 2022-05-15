# frozen_string_literal: true

FactoryBot.define do
  factory :power do
    sequence(:name) {|n| "My Power #{n}" }
    power_type      { 'lesser' }
    source          { 'Black Book: Epistolary Acumen' }
    description     { 'Something cool' }
  end
end
