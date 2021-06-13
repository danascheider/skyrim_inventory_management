# frozen_string_literal: true

DeviseTokenAuth.setup do |config|
  # By default the authorization headers will change after each request. The
  # client is responsible for keeping track of the changing tokens. Change
  # this to false to prevent the Authorization header from changing after
  # each request.
  # config.change_headers_on_each_request = true

  # Limiting the token_cost to just 4 in testing will increase the performance of
  # your test suite dramatically. The possible cost value is within range from 4
  # to 31. It is recommended to not use a value more than 10 in other environments.
  config.token_cost = Rails.env.test? ? 4 : 10

  # This route will be the prefix for all oauth2 redirect callbacks. For
  # example, using the default '/omniauth', the github oauth2 provider will
  # redirect successful authentications to '/omniauth/github/callback'
  config.omniauth_prefix = "/auth"

  # By default we will use callbacks for single omniauth.
  # It depends on fields like email, provider and uid.
  config.default_callbacks = true
end
