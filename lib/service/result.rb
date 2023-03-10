# frozen_string_literal: true

module Service
  class Result
    ERROR_KEYS = [:error, 'error', :errors, 'errors'].freeze
    RESOURCE_KEYS = [:resource, 'resource'].freeze

    attr_reader :errors, :resource

    def initialize(options = {})
      @errors = []

      options.each do |key, value|
        if ERROR_KEYS.include?(key)
          @errors = [value].flatten
        elsif RESOURCE_KEYS.include?(key)
          @resource = value
        end
      end
    end

    def status
      raise NotImplementedError
    end
  end
end
