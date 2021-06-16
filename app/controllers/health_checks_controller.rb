# frozen_string_literal: true

class HealthChecksController < ApplicationController
  skip_before_action :validate_google_oauth_token

  def index
    render json: {}, status: :ok
  end
end
