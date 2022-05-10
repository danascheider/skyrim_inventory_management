# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_jewelry_items_material, class: Canonical::JewelryItemsMaterial do
    association :jewelry_item, factory: :canonical_jewelry_item
    association :material, factory: :canonical_material
    quantity { 2 }
  end
end
