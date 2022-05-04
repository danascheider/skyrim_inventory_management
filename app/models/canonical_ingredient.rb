# frozen_string_literal: true

class CanonicalIngredient < ApplicationRecord
  validates :name, presence: true
  validates :item_code, presence: true, uniqueness: { message: 'must be unique' }
end
