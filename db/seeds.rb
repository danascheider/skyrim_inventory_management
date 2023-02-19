# frozen_string_literal: true

module Seeds
  USER_DATA = {
                uid:   'uruser',
                email: 'uruser@gmail.com',
                name:  'Uruser',
              }.freeze

  module_function

  def seed!
    seed_user!
  end

  def seed_user!
    User.create!(**USER_DATA)
  rescue ActiveRecord::RecordInvalid
    Rails.logger.info "User '#{USER_DATA[:uid]}' with email '#{USER_DATA[:email]}' already exists."
  end
end

Seeds.seed!
