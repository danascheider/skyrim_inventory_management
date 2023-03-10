# frozen_string_literal: true

FactoryBot.define do
  factory :enchantment do
    sequence(:name) {|n| "Enchantment #{n}" }
    strength_unit { 'point' }
  end
end
