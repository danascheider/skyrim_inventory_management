# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'health_checks#index'

  get '/privacy', to: 'utilities#privacy'
  get '/tos', to: 'utilities#tos'
end
