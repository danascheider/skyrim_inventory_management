# frozen_string_literal: true

require 'service/no_content_result'
require 'controller/response'

class VerificationsController < ApplicationController
  # The token will be verified in the before_action defined
  # in the ApplicationController class. If it gets to this
  # point then the token has been verified and the user has
  # been created or updated. This just confirms that the
  # token has been verified server-side and that there is
  # a corresponding user in the system.
  def verify_token
    result = Service::NoContentResult.new

    ::Controller::Response.new(self, result).execute
  end
end
