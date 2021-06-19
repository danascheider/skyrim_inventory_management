# frozen_string_literal: true

class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :shopping_list_items, dependent: :destroy

  validate :one_master_list_per_user

  private

  def one_master_list_per_user
    if master == true && user.master_shopping_list && user.master_shopping_list != self
      errors.add(:master, 'user can only have one master shopping list')
    end
  end
end
