# frozen_string_literal: true

require 'service/no_content_result'
require 'service/method_not_allowed_result'
require 'service/not_found_result'
require 'service/ok_result'

class ShoppingListsController < ApplicationController
  class DestroyService
    MASTER_LIST_ERROR = 'Cannot manually delete a master shopping list'

    def initialize(user, list_id)
      @user = user
      @list_id = list_id
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [MASTER_LIST_ERROR]) if shopping_list.master == true

      master_list = destroy_and_update_master_list_items
      master_list.nil? ? Service::NoContentResult.new : Service::OKResult.new(resource: master_list)
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    end

    private

    attr_reader :user, :list_id

    def shopping_list
      @shopping_list ||= user.shopping_lists.find(list_id)
    end

    def destroy_and_update_master_list_items
      master_list = shopping_list.master_list

      list_items = shopping_list.list_items.map(&:attributes)

      # If shopping_list is the user's last regular shopping list, this will also
      # destroy their master list
      shopping_list.destroy!
      
      if master_list&.persisted?
        list_items.each { |item_attributes| master_list.remove_item_from_child_list(item_attributes) }
        master_list
      end
    end
  end
end
