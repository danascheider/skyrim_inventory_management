# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_weapon, class: Canonical::Weapon do
    name                 { 'Dwarven War Axe' }
    sequence(:item_code) {|n| "123xxx#{n}" }
    category             { 'one-handed' }
    weapon_type          { 'war axe' }
    base_damage          { 12 }
    smithing_perks       { ['Dwarven Smithing'] }
    unit_weight          { 14 }
    purchasable          { true }
    unique_item          { false }
    rare_item            { false }
    quest_item           { false }
    leveled              { false }
    enchantable          { true }
  end
end
