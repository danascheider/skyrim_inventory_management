# frozen_string_literal: true

require 'service/result'

module Service
  class InternalServerErrorResult < Result
    def status
      :internal_server_error
    end
  end
end
