# frozen_string_literal: true

require 'service/ok_result'
require 'service/not_found_result'
require 'service/unprocessable_entity_result'
require 'service/method_not_allowed_result'

class ShoppingListItemsController < ApplicationController
  class UpdateService
    MASTER_LIST_ERROR = 'Cannot manually update list items on a master shopping list'

    def initialize(user, item_id, params)
      @user = user
      @item_id = item_id
      @params = params
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [MASTER_LIST_ERROR]) if shopping_list.master == true

      delta_qty = params[:quantity] ? params[:quantity].to_i - list_item.quantity : 0
      old_notes = list_item.notes

      if list_item.update(params)
        shopping_list.touch
        master_list_item = master_list.update_item_from_child_list(list_item.description, delta_qty, old_notes, params[:notes])
        Service::OKResult.new(resource: [master_list_item, list_item])
      else
        Service::UnprocessableEntityResult.new(errors: list_item.error_array)
      end
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    end
    
    private

    attr_reader :user, :item_id, :params

    def master_list
      @master_list ||= list_item.list.master_list
    end

    def shopping_list
      @shopping_list ||= list_item.list
    end

    def list_item
      @list_item ||= ShoppingListItem.belonging_to_user(user).find(item_id)
    end
  end
end