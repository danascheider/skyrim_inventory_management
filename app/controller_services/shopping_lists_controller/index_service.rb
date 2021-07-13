# frozen_string_literal: true

require 'service/ok_result'
require 'service/internal_server_error_result'

class ShoppingListsController < ApplicationController
  class IndexService
    def initialize(user)
      @user = user
    end

    def perform
      Service::OKResult.new(resource: user.shopping_lists.index_order)
    rescue => e
      Rails.logger.error "Internal Server Error: #{e.message}"
      Service::InternalServerErrorResult.new(errors: [e.message])
    end

    private

    attr_reader :user
  end
end
