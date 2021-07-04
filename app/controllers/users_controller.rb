# frozen_string_literal: true

require 'controller/response'

class UsersController < ApplicationController
  # current_user is set in the before_action that verifies the
  # user's OAuth token from Google.
  def current
    result = ShowService.new(current_user).perform

    ::Controller::Response.new(self, result).execute
  end
end
