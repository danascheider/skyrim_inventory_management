# frozen_string_literal: true

require 'service/result'

module Service
  class CreatedResult < Result
    def status
      :created
    end
  end
end
