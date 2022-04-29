# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_armor do
    name      { 'fur armor' }
    weight    { 'light armor' }
    body_slot { 'body' }
  end
end
