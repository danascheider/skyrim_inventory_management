# frozen_string_literal: true

class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :shopping_list_items, dependent: :destroy

  validate :one_master_list_per_user

  after_create :ensure_master_list_present

  private

  def one_master_list_per_user
    if master == true && user.master_shopping_list && user.master_shopping_list != self
      errors.add(:master, 'user can only have one master shopping list')
    end
  end

  def ensure_master_list_present
    if user.master_shopping_list.nil?
      user.shopping_lists.create!(master: true)
    end
  end
end
