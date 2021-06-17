# frozen_string_literal: true

class UsersController < ApplicationController
  def logged_in
    render json: current_user, status: :ok
  end
end
