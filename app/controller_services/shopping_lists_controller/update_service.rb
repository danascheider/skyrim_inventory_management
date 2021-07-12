# frozen_string_literal: true

require 'service/ok_result'
require 'service/method_not_allowed_result'
require 'service/not_found_result'
require 'service/unprocessable_entity_result'

class ShoppingListsController < ApplicationController
  class UpdateService
    AGGREGATE_LIST_ERROR = 'Cannot manually update an aggregate shopping list'
    DISALLOWED_UPDATE_ERROR = 'Cannot make a regular shopping list an aggregate list'

    def initialize(user, list_id, params)
      @user = user
      @list_id = list_id
      @params = params
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [AGGREGATE_LIST_ERROR]) if shopping_list.aggregate == true
      return Service::UnprocessableEntityResult.new(errors: [DISALLOWED_UPDATE_ERROR]) if params[:aggregate] == true

      if shopping_list.update(params)
        Service::OKResult.new(resource: shopping_list)
      else
        Service::UnprocessableEntityResult.new(errors: shopping_list.error_array)
      end
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    end

    private

    attr_reader :user, :list_id, :params

    def shopping_list
      @shopping_list ||= user.shopping_lists.find(list_id)
    end
  end
end
