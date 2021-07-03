# frozen_string_literal: true

module Controller
  class Response
    def initialize(controller, result, options = {})
      @controller = controller
      @result = result
      @options = options
    end

    def execute
      if result.unauthorized?
        controller.head :unauthorized
      elsif result.not_found?
        controller.head :not_found
      elsif result.method_not_allowed?
        controller.render json: { errors: result.errors }, status: :method_not_allowed
      elsif result.unprocessable_entity?
        controller.render json: { errors: result.errors }, status: :unprocessable_entity
      elsif result.ok?
        controller.render json: result.resource, status: :ok
      elsif result.created?
        controller.render json: result.resource, status: :created
      elsif result.no_content?
        controller.head :no_content
      end
    end

    private

    attr_reader :controller, :result, :options
  end
end
