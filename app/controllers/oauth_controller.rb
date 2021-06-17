# frozen_string_literal: true

class OauthController < ApplicationController
  def sign_in
    payload = validate_id_token

    render json: { error: 'Expired OAuth token' }, status: :unauthorized if expired?(payload['exp'])

    user = User.create_for_google(payload)
    session[:current_user_uid] = user.uid
    
    render json: user
  end

  # def sign_out
  # end

  private

  def validate_id_token
    GoogleIDToken::Validator.new.check(params[:id_token], configatron.google_oauth_client_id)
  end

  def expired?(expiry)
    Time.at(expiry.to_i) < Time.now
  end
end
