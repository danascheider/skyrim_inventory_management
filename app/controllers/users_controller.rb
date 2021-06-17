# frozen_string_literal: true

class UsersController < ApplicationController
  # current_user is set in the before_action that verifies the
  # user's OAuth token from Google.
  def current
    render json: current_user, status: :ok
  end
end
