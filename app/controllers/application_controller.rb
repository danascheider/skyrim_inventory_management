# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :validate_google_oauth_token

  private

  def current_user
    @_current_user ||= session[:current_user_uid] && User.find_by_uid(session[:current_user_uid])
  end

  def validate_google_oauth_token
    validator = GoogleIDToken::Validator.new
    payload = validator.check(params[:id_token], configatron.google_oauth_client_id)

    if current?(payload['exp'])
      user = User.create_for_google(payload)
    else
      Rails.logger.error('User authenticated with expired token')
      head :unauthorized
    end
  rescue GoogleIDToken::AudienceMismatchError => e
    Rails.logger.error "Unsuccessful login attempt -- Could not verify OAuth token: #{e.message}"
    render json: { error: 'Could not verify OAuth token' }, status: :unauthorized
  end

  def current?(seconds_since_unix_epoch)
    Time.at(seconds_since_unix_epoch) >= Time.now
  end
end
