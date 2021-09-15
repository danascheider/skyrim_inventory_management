# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_property do
    alchemy_lab_available { true }
    arcane_enchanter_available { true }
    forge_available { false }
  end
end
