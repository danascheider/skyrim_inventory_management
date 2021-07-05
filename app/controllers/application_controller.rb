# frozen_string_literal: true

require 'controller/response'

class ApplicationController < ActionController::API
  before_action :validate_google_oauth_token

  # Had to make this a public attr_accessor so it can be set within the
  # ApplicationController::AuthorizationService. This value should not
  # be set anywhere outside of either that class or this one.
  attr_accessor :current_user

  private

  def validate_google_oauth_token
    result = AuthorizationService.new(self, id_token).perform

    ::Controller::Response.new(self, result).execute if result.present?
  end

  def id_token
    request.headers['Authorization']&.gsub('Bearer ', '')
  end
end
