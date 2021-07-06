# frozen_string_literal: true

require 'service/result'

module Service
  class MethodNotAllowedResult < Result
    def status
      :method_not_allowed
    end
  end
end
