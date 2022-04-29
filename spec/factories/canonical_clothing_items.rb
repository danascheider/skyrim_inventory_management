FactoryBot.define do
  factory :canonical_clothing_item do
    sequence(:name) {|n| "Clothing Item #{n}"  }
    unit_weight { 9.9 }
    quest_item { false }
  end
end
