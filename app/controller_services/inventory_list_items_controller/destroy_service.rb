# frozen_string_literal: true

require 'service/no_content_result'

class InventoryListItemsController < ApplicationController
  class DestroyService
    def initialize(user, item_id)
      @user    = user
      @item_id = item_id
    end

    def perform
      aggregate_list_item = nil

      ActiveRecord::Base.transaction do
        list_item.destroy!
        aggregate_list_item = aggregate_list.remove_item_from_child_list(list_item.attributes)
      end

      Service::NoContentResult.new
    end

    private

    attr_reader :user, :item_id

    def aggregate_list
      @aggregate_list ||= inventory_list.aggregate_list
    end

    def inventory_list
      @inventory_list ||= list_item.list
    end

    def list_item
      @list_item ||= user.inventory_list_items.find(item_id)
    end
  end
end
