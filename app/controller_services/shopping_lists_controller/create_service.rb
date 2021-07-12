# frozen_string_literal: true

require 'service/created_result'
require 'service/unprocessable_entity_result'
require 'service/method_not_allowed_result'
require 'service/ok_result'

class ShoppingListsController < ApplicationController
  class CreateService
    AGGREGATE_LIST_ERROR = 'Cannot manually create an aggregate shopping list'

    def initialize(user, params)
      @user = user
      @params = params
    end

    def perform
      return Service::UnprocessableEntityResult.new(errors: [AGGREGATE_LIST_ERROR]) if params[:aggregate]

      shopping_list = user.shopping_lists.new(params)
      preexisting_aggregate_list = user.aggregate_shopping_list

      if shopping_list.save
        # Check if the aggregate shopping list is newly created and return it too if so
        resource = preexisting_aggregate_list ? shopping_list : [user.aggregate_shopping_list, shopping_list]
        Service::CreatedResult.new(resource: resource)
      else
        Service::UnprocessableEntityResult.new(errors: shopping_list.error_array)
      end
    rescue => e
      Service::InternalServerErrorResult.new(errors: [e.message])
    end

    private

    attr_reader :user, :params
  end
end
