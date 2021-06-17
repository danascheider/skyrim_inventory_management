# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :validate_google_oauth_token

  attr_reader :current_user

  private

  def validate_google_oauth_token
    validator = GoogleIDToken::Validator.new
    payload = validator.check(id_token, configatron.google_oauth_client_id)

    if current?(payload['exp'])
      @current_user = User.create_for_google(payload)
    else
      Rails.logger.error('User authenticated with expired token')
      @current_user = nil
      render json: { error: 'Expired authentication token. Try logging out and logging in again.' }, status: :unauthorized
    end
  rescue GoogleIDToken::AudienceMismatchError => e
    Rails.logger.error "Unsuccessful login attempt -- Could not verify OAuth token: #{e.message}"
    render json: { error: 'Could not verify OAuth token' }, status: :unauthorized
  end

  def id_token
    request.headers['Authorization'].gsub('Bearer ', '')
  end

  def oauth_audience
    request.headers['X-Oauth-Aud']
  end

  def current?(seconds_since_unix_epoch)
    Time.at(seconds_since_unix_epoch) >= Time.now
  end
end
