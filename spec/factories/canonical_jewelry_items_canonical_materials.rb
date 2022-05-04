# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_jewelry_items_canonical_material do
    canonical_jewelry_item
    canonical_material
    quantity { 2 }
  end
end
