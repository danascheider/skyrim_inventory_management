# frozen_string_literal: true

class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User

  devise :omniauthable, :rememberable, :database_authenticatable

  def self.create_for_google(data)
    where(uid: data['email']).first_or_initialize.tap do |user|
      user.provider = 'google_oauth2'
      user.uid = data['email']
      user.email = data['email']
      user.password = Devise.friendly_token[0,20]
      user.password_confirmation = user.password
      user.save!
    end
  end
end
