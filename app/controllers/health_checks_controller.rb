# frozen_string_literal: true

class HealthChecksController < ApplicationController
  def index
    render json: {}, status: :ok
  end
end
