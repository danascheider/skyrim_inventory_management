# frozen_string_literal: true

class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list
end
