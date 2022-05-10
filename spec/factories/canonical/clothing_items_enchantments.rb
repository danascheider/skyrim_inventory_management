# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_clothing_items_enchantment, class: Canonical::ClothingItemsEnchantment do
    canonical_clothing_item
    enchantment
  end
end
