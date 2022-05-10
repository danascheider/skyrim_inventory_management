# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_armor, class: Canonical::Armor do
    name                 { 'fur armor' }
    sequence(:item_code) {|n| "123abc#{n}" }
    weight               { 'light armor' }
    body_slot            { 'body' }
    unit_weight          { 1.0 }
  end
end
