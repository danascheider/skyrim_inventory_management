# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_potion, class: Canonical::Potion do
    name { 'My Potion' }
    sequence(:item_code) {|n| "xx123x#{n}" }
    unit_weight { 0.5 }
    potion_type { 'potion' }
    purchasable { true }
    unique_item { false }
    rare_item { false }
    quest_item { false }
  end
end
