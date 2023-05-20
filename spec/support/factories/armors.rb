# frozen_string_literal: true

FactoryBot.define do
  factory :armor do
    game

    name { 'Fur Helmet' }
    unit_weight { 1 }
    weight { 'light' }
  end
end
