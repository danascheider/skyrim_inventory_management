# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_misc_item, class: Canonical::MiscItem do
    name { "Wylandria's Soul Gem" }
    sequence(:item_code) {|n| "xx123x#{n}" }
    unit_weight { 1.0 }
    item_types { %w[miscellaneous] }
    add_on { 'base' }
    collectible { true }
    purchasable { true }
    unique_item { false }
    rare_item { false }
    quest_item { false }
    quest_reward { false }
  end
end
