# frozen_string_literal: true

class AuthorizationController < ApplicationController
  def authorize
    resp = HTTParty.get(auth_url)

    # Example Google APIs response:
    # {
    #   "iss"=>"accounts.google.com",
    #   "azp"=>"somevalue.apps.googleusercontent.com",
    #   "aud"=>"somevalue.apps.googleusercontent.com",
    #   "sub"=>"109986944037938925200",
    #   "email"=>"dana.scheider@gmail.com",
    #   "email_verified"=>"true",
    #   "at_hash"=>"BJFaIoiJhV7OTViZYQUXog",
    #   "name"=>"Dana Scheider",
    #   "picture"=>"https://lh3.googleusercontent.com/a-/AOh14GiscOI-4doBiwg33_ujic6h_oc1ByqwSI4BZFk0yg=s96-c",
    #   "given_name"=>"Dana",
    #   "family_name"=>"Scheider",
    #   "locale"=>"en",
    #   "iat"=>"1623713839",
    #   "exp"=>"1623717439",
    #   "jti"=>"409efe9fab62b1b85d37cf8935cb905aea3e3f3e",
    #   "alg"=>"RS256",
    #   "kid"=>"6a1d26d992be7a4b689bdce1911f4e9adc75d9f1",
    #   "typ"=>"JWT"
    # }

    @user = User.create_for_google(resp.parsed_response)
    token = @user.generate_access_token!

    set_headers(token)

    render json: @user
  rescue User::InvalidTokenError => e
    Rails.logger.error('Unable to log in user: OAuth access token corresponded to a different email')
    render json: error_payload, status: :unauthorized
  end

  private

  def error_payload
    {
      error: 'Invalid OAuth token for user'
    }
  end

  def auth_url
    "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params[:id_token]}"
  end

  def set_headers(tokens)
    response.set_header('access-token', token.encrypted_token)
    response.set_header('client-id', token.encrypted_client_id)
    response.set_header('expiry', token.expiry.to_s)
    response.set_header('uid', @user.uid.to_s)
    response.set_header('token-type', 'Bearer'.to_s)
  end
end
