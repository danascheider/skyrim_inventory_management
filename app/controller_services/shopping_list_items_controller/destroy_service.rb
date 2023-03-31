# frozen_string_literal: true

require 'service/ok_result'
require 'service/not_found_result'
require 'service/method_not_allowed_result'
require 'service/internal_server_error_result'

class ShoppingListItemsController < ApplicationController
  class DestroyService
    AGGREGATE_LIST_ERROR = 'Cannot manually delete list item from aggregate shopping list'

    def initialize(user, item_id)
      @user = user
      @item_id = item_id
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [AGGREGATE_LIST_ERROR]) if shopping_list.aggregate == true

      ActiveRecord::Base.transaction do
        shopping_list_item.destroy!
        aggregate_list.remove_item_from_child_list(shopping_list_item.attributes)
      end

      Service::OKResult.new(resource: [aggregate_list.reload, shopping_list.reload])
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    rescue StandardError => e
      Rails.logger.error "Internal Server Error: #{e.message}"
      Service::InternalServerErrorResult.new(errors: [e.message])
    end

    private

    attr_reader :user, :item_id

    def game
      @game ||= shopping_list.game
    end

    def aggregate_list
      @aggregate_list ||= shopping_list.aggregate_list
    end

    def shopping_list
      @shopping_list = shopping_list_item.list
    end

    def shopping_list_item
      @shopping_list_item ||= user.shopping_list_items.find(item_id)
    end
  end
end
