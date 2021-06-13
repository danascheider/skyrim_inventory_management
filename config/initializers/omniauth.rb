# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           configatron.google_oauth2_key,
           configatron.google_oauth2_secret,
           scope: 'userinfo.email',
           client_options: {
             ssl: {
               ca_file: Rails.root.join('sim-api.danascheider.com.crt')
             }
           }
end

OmniAuth.config.allowed_request_methods = %i[get post put patch delete head options trace]
