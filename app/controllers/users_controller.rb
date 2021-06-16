# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    render json: current_user, status: :ok
  end
end
