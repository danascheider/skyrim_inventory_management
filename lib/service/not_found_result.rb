# frozen_string_literal: true

require 'service/result'

module Service
  class NotFoundResult < Result
    def status
      :not_found
    end
  end
end
