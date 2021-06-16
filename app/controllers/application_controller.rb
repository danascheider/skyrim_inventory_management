# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :validate_google_oauth_token

  private

  def current_user
    @_current_user ||= session[:current_user_uid] && User.find_by_uid(session[:current_user_uid])
  end

  def validate_google_oauth_token
    resp = HTTParty.get(google_oauth_confirmation_endpoint)

    unless resp.success?
      Rails.logger.error("HTTParty returned error #{resp.code} for ID token #{params[:id_token]}: #{resp.body}")
      @_current_user = nil
      session.delete(:current_user_uid)

      render json: { error: 'Could not confirm OAuth token' }, status: :unauthorized
    end

    user = User.create_for_google(resp.parsed_response)
    session[:current_user_uid] = user.uid
  end

  def google_oauth_confirmation_endpoint
    "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params[:id_token]}"
  end
end
