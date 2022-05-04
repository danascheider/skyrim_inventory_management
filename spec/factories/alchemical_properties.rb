# frozen_string_literal: true

FactoryBot.define do
  factory :alchemical_property do
    sequence(:name) {|n| "Alchemical Property #{n}" }
  end
end
