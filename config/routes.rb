# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'health_checks#index'

  get '/auth/verify_token', to: 'verifications#verify_token', as: 'verify_token'
  get '/users/current', to: 'users#current', as: 'current_user'

  resources :shopping_lists do
    resources :shopping_list_items, shallow: true, except: %i[index show]
  end

  get '/privacy', to: 'utilities#privacy'
  get '/tos', to: 'utilities#tos'
end
