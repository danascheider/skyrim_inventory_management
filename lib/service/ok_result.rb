# frozen_string_literal: true

require 'service/result'

module Service
  class OKResult < Result
    def status
      :ok
    end
  end
end
