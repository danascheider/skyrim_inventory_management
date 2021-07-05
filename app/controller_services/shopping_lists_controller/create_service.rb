# frozen_string_literal: true

require 'service/created_result'
require 'service/unprocessable_entity_result'

class ShoppingListsController < ApplicationController
  class CreateService
    MASTER_LIST_ERROR = 'Cannot manually create a master shopping list'

    def initialize(user, params)
      @user = user
      @params = params
    end

    def perform
      return Service::UnprocessableEntityResult.new(errors: [MASTER_LIST_ERROR]) if params[:master]

      shopping_list = user.shopping_lists.new(params)
      preexisting_master_list = user.master_shopping_list

      if shopping_list.save
        # Check if the master shopping list is newly created and return it too if so
        resource = preexisting_master_list ? shopping_list : [user.master_shopping_list, shopping_list]
        Service::CreatedResult.new(resource: resource)
      else
        Service::UnprocessableEntityResult.new(errors: assemble_error_messages(shopping_list.errors))
      end
    end

    private

    attr_reader :user, :params

    def assemble_error_messages(data)
      data.map { |error| "#{error.attribute.capitalize} #{error.message}" }
    end

    def new_master_list
      return user.shopping_lists.new(master: true, title: 'Master') if user.master_shopping_list.nil?
    end
  end
end
