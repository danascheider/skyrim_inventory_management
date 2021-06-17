# frozen_string_literal: true

class User < ApplicationRecord
  validates :uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.create_for_google(data)
    where(uid: data['email']).first_or_initialize.tap do |user|
      user.uid = data['email']
      user.email = data['email']
      user.name = data['name']
      user.save!
    end
  end
end
