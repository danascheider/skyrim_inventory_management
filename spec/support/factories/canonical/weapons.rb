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
  end
end
