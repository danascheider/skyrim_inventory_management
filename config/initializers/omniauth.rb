# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, configatron.google_oauth2_key, configatron.google_oauth2_secret, scope: 'email'
end
