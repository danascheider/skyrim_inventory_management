# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'health_checks#index'

  get '/users/logged_in', to: 'users#logged_in', as: 'logged_in_user'

  get '/privacy', to: 'utilities#privacy'
  get '/tos', to: 'utilities#tos'
end
