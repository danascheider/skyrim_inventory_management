# frozen_string_literal: true

require 'service/method_not_allowed_result'
require 'service/not_found_result'
require 'service/ok_result'
require 'service/internal_server_error_result'

class ShoppingListsController < ApplicationController
  class DestroyService
    AGGREGATE_LIST_ERROR = 'Cannot manually delete an aggregate shopping list'

    def initialize(user, list_id)
      @user = user
      @list_id = list_id
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [AGGREGATE_LIST_ERROR]) if shopping_list.aggregate == true

      ids = game.shopping_lists.count == 2 ? [aggregate_list.id, shopping_list.id] : [shopping_list.id]

      destroy_and_update_aggregate_list_items!

      resource = aggregate_list&.persisted? ? { deleted: ids, aggregate: aggregate_list } : { deleted: ids }

      Service::OKResult.new(resource:)
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    rescue StandardError => e
      Rails.logger.error "Internal Server Error: #{e.message}"
      Service::InternalServerErrorResult.new(errors: [e.message])
    end

    private

    attr_reader :user, :list_id

    def shopping_list
      @shopping_list ||= user.shopping_lists.find(list_id)
    end

    def aggregate_list
      game.aggregate_shopping_list
    end

    def game
      @game ||= shopping_list.game
    end

    def destroy_and_update_aggregate_list_items!
      aggregate_list = shopping_list.aggregate_list

      list_items = shopping_list.list_items.map(&:attributes)

      ActiveRecord::Base.transaction do
        # If shopping_list is the user's last regular shopping list, this will also
        # destroy their aggregate list (see the Aggregatable concern)
        shopping_list.destroy!

        list_items.each {|item_attributes| aggregate_list.remove_item_from_child_list(item_attributes) } if aggregate_list&.persisted?
      end
    end
  end
end
