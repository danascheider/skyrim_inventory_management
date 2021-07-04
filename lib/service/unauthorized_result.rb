# frozen_string_literal: true

require 'service/result'

module Service
  class UnauthorizedResult < Result
    def status
      :unauthorized
    end
  end
end
