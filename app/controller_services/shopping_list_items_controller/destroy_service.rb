# frozen_string_literal: true

require 'service/no_content_result'
require 'service/ok_result'
require 'service/not_found_result'
require 'service/method_not_allowed_result'

class ShoppingListItemsController < ApplicationController
  class DestroyService
    MASTER_LIST_ERROR = 'Cannot manually delete list item from master shopping list'

    def initialize(user, item_id)
      @user = user
      @item_id = item_id
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [MASTER_LIST_ERROR]) if shopping_list.master == true

      shopping_list_item.destroy!
      shopping_list.touch
      master_list_item = master_list.remove_item_from_child_list(shopping_list_item.attributes)
      master_list_item.nil? ? Service::NoContentResult.new : Service::OKResult.new(resource: master_list_item)
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    end

    private

    attr_reader :user, :item_id

    def master_list
      @master_list ||= shopping_list_item.list.master_list
    end

    def shopping_list
      @shopping_list = shopping_list_item.list
    end

    def shopping_list_item
      @shopping_list_item ||= user.shopping_list_items.find(item_id)
    end
  end
end
