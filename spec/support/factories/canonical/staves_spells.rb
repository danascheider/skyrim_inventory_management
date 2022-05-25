# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_staves_spell, class: Canonical::StavesSpell do
    spell
    association :staff, factory: :canonical_staff
  end
end
