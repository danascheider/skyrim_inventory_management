# frozen_string_literal: true

require 'service/result'

module Service
  class UnprocessableEntityResult < Result
    def status
      :unprocessable_entity
    end
  end
end
