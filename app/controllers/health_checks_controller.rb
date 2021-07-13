# frozen_string_literal: true

require 'service/ok_result'
require 'controller/response'

class HealthChecksController < ApplicationController
  skip_before_action :validate_google_oauth_token

  def index
    result = Service::OKResult.new(resource: {})

    ::Controller::Response.new(self, result).execute
  end
end
