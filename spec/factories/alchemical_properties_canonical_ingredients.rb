# frozen_string_literal: true

FactoryBot.define do
  factory :alchemical_properties_canonical_ingredient do
    alchemical_property
    canonical_ingredient
    priority { 2 }
  end
end
