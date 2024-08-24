# frozen_string_literal: true

FactoryBot.define do
  factory :spell do
    sequence(:name) {|n| "Awesome Spell #{n}" }
    school { 'Conjuration' }
    level { 'Adept' }
    description { 'Destroys enemies on sight' }
    base_duration { 5 }
    add_on { 'base' }
  end
end
