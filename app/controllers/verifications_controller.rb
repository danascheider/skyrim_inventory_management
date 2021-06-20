# frozen_string_literal: true

class VerificationsController < ApplicationController
  # The token will be verified in the before_action defined
  # in the ApplicationController class. If it gets to this
  # point then the token has been verified and the user has
  # been created or updated. This just confirms that the
  # token has been verified server-side and that there is
  # a corresponding user in the system.
  def verify_token
    head :no_content
  end
end
