# frozen_string_literal: true

class User < ApplicationRecord
  validates :uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  has_many :shopping_lists, dependent: :destroy

  def self.create_or_update_for_google(data)
    where(uid: data['email']).first_or_initialize.tap do |user|
      user.uid = data['email']
      user.email = data['email']
      user.name = data['name']
      user.image_url = data['picture']
      user.save!
    end
  end

  def aggregate_shopping_list
    shopping_lists.find_by(aggregate: true)
  end

  def shopping_list_items
    ShoppingListItem.belonging_to_user(self)
  end
end
