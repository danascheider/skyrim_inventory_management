# frozen_string_literal: true

class CanonicalIngredient < ApplicationRecord
  has_and_belongs_to_many :alchemical_properties

  validates :name, presence: true
  validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
end
