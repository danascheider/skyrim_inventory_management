# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'health_checks#index'

  post '/auth/google_oauth2', to: 'oauth#sign_in'

  get '/privacy', to: 'utilities#privacy'
  get '/tos', to: 'utilities#tos'
end
