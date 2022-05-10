# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_jewelry_items_enchantment, class: Canonical::JewelryItemsEnchantment do
    association :jewelry_item, factory: :canonical_jewelry_item
    enchantment
    strength { 12 }
  end
end
