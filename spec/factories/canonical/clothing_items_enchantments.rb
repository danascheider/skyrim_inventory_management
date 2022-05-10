# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_clothing_items_enchantment, class: Canonical::ClothingItemsEnchantment do
    association :clothing_item, factory: :canonical_clothing_item
    enchantment
  end
end
