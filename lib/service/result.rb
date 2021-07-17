# frozen_string_literal: true

module Service
  class Result
    attr_reader :errors, :resource

    def initialize(options = {})
      @errors = []

      options.each do |key, value|
        if [:error, 'error', :errors, 'errors'].include?(key)
          @errors = [value].flatten
        elsif [:resource, 'resource'].include?(key)
          @resource = value
        end
      end
    end

    def status
      raise NotImplementedError
    end
  end
end
