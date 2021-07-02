# frozen_string_literal: true

module Service
  class Result
    attr_reader :errors, :resource

    def initialize(options)
      @errors = []

      options.each do |key, value|
        if [:error, 'error', :errors, 'errors'].include?(key)
          @errors = [value].flatten
        elsif [:resource, 'resource'].include?(key)
          @resource = value
        end
      end
    end

    ############################################################
    ### PUBLIC INSTANCE METHODS                              ###
    ### Instance methods all return false on the base class. ###
    ### These should be set to the appropriate values for    ###
    ### each subclass.                                       ###
    ############################################################

    # These methods are blanket methods indicating whether a request
    # was successful or not. One of these methods will be set to `true`
    # in each subclass. One of the methods below will additionally be
    # set to true to indicate the nature of the success or failure
    # response.

    def success?
      false
    end

    def failure?
      false
    end

    # These methods indicate the specific type (i.e., status code) of
    # success response. One of these will be overridden to be `true` in
    # each subclass that represents a successful response.

    def ok? # 200
      false
    end

    def created? # 201
      false
    end

    def no_content? # 204
      false
    end


    # These methods indicate the specific type of error response. One
    # of these will be overridden to be `true` in each subclass that
    # represents an error response.

    def unauthorized? # 401
      false
    end

    def not_found? # 404
      false
    end

    def method_not_allowed? # 405
      false
    end

    def unprocessable_entity? # 422
      false
    end
  end
end
