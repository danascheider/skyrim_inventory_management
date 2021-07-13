# frozen_string_literal: true

require 'service/unauthorized_result'
require 'service/internal_server_error_result'

class ApplicationController < ActionController::API
  class AuthorizationService
    def initialize(controller, token)
      @controller = controller
      @token = token
    end

    def perform
      validator = GoogleIDToken::Validator.new
      payload = validator.check(token, configatron.google_oauth_client_id)

      if current?(payload['exp'])
        controller.current_user = User.create_or_update_for_google(payload)
        return
      end

      Service::UnauthorizedResult.new(errors: ['Expired authentication token. Try logging out and logging in again'])
    rescue GoogleIDToken::ValidationError => e
      Rails.logger.error "Token validation failed -- #{e.message}"
      Service::UnauthorizedResult.new(errors: ['Google OAuth token validation failed'])
    rescue GoogleIDToken::CertificateError => e
      Rails.logger.error "Problem with OAuth certificate -- #{e.message}"
      Service::UnauthorizedResult.new(errors: ['Invalid OAuth certificate'])
    rescue => e
      Rails.logger.error "Internal Server Error: #{e.message}"
      Service::InternalServerErrorResult.new(errors: [e.message])
    end

    private

    def current?(seconds_since_unix_epoch)
      Time.at(seconds_since_unix_epoch) >= Time.now
    end

    attr_reader :controller, :token
  end
end
