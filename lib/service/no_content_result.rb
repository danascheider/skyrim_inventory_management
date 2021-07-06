# frozen_string_literal: true

require 'service/result'

module Service
  class NoContentResult < Result
    def status
      :no_content
    end
  end
end
