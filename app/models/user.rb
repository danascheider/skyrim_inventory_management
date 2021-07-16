# frozen_string_literal: true

class User < ApplicationRecord
  has_many :games, dependent: :destroy

  validates :uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.create_or_update_for_google(data)
    where(uid: data['email']).first_or_initialize.tap do |user|
      user.uid = data['email']
      user.email = data['email']
      user.name = data['name']
      user.image_url = data['picture']
      user.save!
    end
  end

  def shopping_lists
    ShoppingList.belonging_to_user(self)
  end

  def shopping_list_items
    ShoppingListItem.belonging_to_user(self)
  end
end
