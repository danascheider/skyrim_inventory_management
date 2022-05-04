# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_jewelry_items_enchantment do
    canonical_jewelry_item
    enchantment
    strength { 12 }
  end
end
