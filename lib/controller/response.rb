# frozen_string_literal: true

module Controller
  class Response
    def initialize(controller, result, options = {})
      @controller = controller
      @result = result
      @options = options
    end

    def execute
      if result.errors.blank? && !result.resource
        controller.head result.status
      elsif result.errors.any?
        controller.render json: { errors: result.errors }, status: result.status
      else
        controller.render json: result.resource, status: result.status
      end
    end

    private

    attr_reader :controller, :result, :options
  end
end
