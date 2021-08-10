# frozen_string_literal: true

require 'service/created_result'

class InventoryListItemsController < ApplicationController
  class CreateService
    def initialize(user, list_id, params)
      @user    = user
      @list_id = list_id
      @params  = params
    end

    def perform
      item                = inventory_list.list_items.create!(params)
      aggregate_list_item = aggregate_list.add_item_from_child_list(item)
      Service::CreatedResult.new(resource: [aggregate_list_item, item])
    end

    private

    attr_reader :user, :list_id, :params

    def aggregate_list
      @aggregate_list ||= inventory_list.aggregate_list
    end

    def inventory_list
      @inventory_list ||= user.inventory_lists.find(list_id)
    end
  end
end
