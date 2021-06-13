# frozen_string_literal: true

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  root to: 'health_checks#index'

  get '/privacy', to: 'utilities#privacy'
  get '/tos', to: 'utilities#tos'
end
