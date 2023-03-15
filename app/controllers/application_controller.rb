# frozen_string_literal: true

require 'controller/response'

class ApplicationController < ActionController::API
  before_action :authenticate_user!

  # Had to make this a public attr_accessor so it can be set within the
  # ApplicationController::AuthorizationService. This value should not
  # be set anywhere outside of either that class or this one.
  attr_accessor :current_user

  private

  def authenticate_user!
    result = AuthorizationService.new(self, google_access_token).perform

    ::Controller::Response.new(self, result).execute if result.present?
  end

  def google_access_token
    return if request.headers['Authorization'].blank?

    request.headers['Authorization'].gsub(/bearer /i, '')
  end
end
