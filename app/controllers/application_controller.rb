# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :validate_google_oauth_token

  private

  def current_user
    @_current_user ||= session[:current_user_uid] && User.find_by_uid(session[:current_user_uid])
  end

  def void_user
    @_current_user = nil
    session.delete(:current_user_uid)
  end

  def validate_google_oauth_token
    validator = GoogleIDToken::Validator.new
    payload = validator.check(params[:id_token], configatron.google_oauth_client_id)

    if current?(payload['exp'])
      user = User.create_for_google(resp.parsed_response)
      session[:current_user_uid] = user.uid
    else
      Rails.logger.error('User authenticated with expired token')
      void_user
      head :unauthorized
    end
  rescue GoogleIDToken::AudienceMismatchError => e
    Rails.logger.error "Unsuccessful login attempt -- Could not verify OAuth token: #{e.message}"
    void_user
    render json: { error: 'Could not verify OAuth token' }, status: :unauthorized
  end

  def current?(seconds_since_unix_epoch)
    Time.at(seconds_since_unix_epoch) >= Time.now
  end
end
