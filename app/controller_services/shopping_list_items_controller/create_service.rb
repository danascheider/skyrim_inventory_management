# frozen_string_literal: true

require 'service/created_result'
require 'service/not_found_result'
require 'service/unprocessable_entity_result'
require 'service/method_not_allowed_result'
require 'service/ok_result'

class ShoppingListItemsController < ApplicationController
  class CreateService
    MASTER_LIST_ERROR = 'Cannot manually manage items on a master shopping list'

    def initialize(user, list_id, params)
      @user = user
      @list_id = list_id
      @params = params
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [MASTER_LIST_ERROR]) if shopping_list.master == true

      preexisting_item = shopping_list.list_items.find_by(description: params[:description])
      item = ShoppingListItem.combine_or_new(params.merge(list_id: list_id))

      if item.save
        shopping_list.touch
        master_list_item = master_list.add_item_from_child_list(item)
        if preexisting_item.blank?
          Service::CreatedResult.new(resource: [master_list_item, item])
        else
          Service::OKResult.new(resource: [master_list_item, item])
        end
      else
        Service::UnprocessableEntityResult.new(errors: item.error_array)
      end
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    end

    private

    attr_reader :user, :list_id, :params

    def shopping_list
      @shopping_list ||= user.shopping_lists.find(list_id)
    end

    def master_list
      shopping_list.master_list
    end
  end
end
