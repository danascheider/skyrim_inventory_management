# frozen_string_literal: true

class AuthorizationController < ApplicationController
  def get_authorization
    response = HTTParty.get(auth_url)

    @user = User.create_for_google(response.parsed_response)
    tokens = @user.create_new_auth_token
    @user.save

    render json: @user
  end

  private

  def auth_url
    "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params[:id_token]}"
  end

  def set_headers(tokens)
    headers['access-token'] = tokens['access-tokens'].to_s
    headers['client'] = tokens['client'].to_s
    headers['expiry'] = tokens['expiry'].to_s
    headers['uid'] = @user.uid
    headers['token-type'] = tokens['token-type'].to_s
  end
end
