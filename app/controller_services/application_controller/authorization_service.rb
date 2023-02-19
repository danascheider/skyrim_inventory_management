# frozen_string_literal: true

require 'service/unauthorized_result'
require 'service/internal_server_error_result'

class ApplicationController < ActionController::API
  class AuthorizationService
    def initialize(controller)
      @controller = controller
    end

    def perform
      if User.first.nil?
        Rails.logger.error 'No users exist'
        return Service::InternalServerErrorResult.new(errors: ['Attempted to set current user but there are no users'])
      end

      controller.current_user = User.first
      nil
    end

    private

    attr_reader :controller
  end
end
