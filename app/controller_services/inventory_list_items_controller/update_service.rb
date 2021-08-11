# frozen_string_literal: true

require 'service/ok_result'
require 'service/not_found_result'
require 'service/unprocessable_entity_result'
require 'service/method_not_allowed_result'

class InventoryListItemsController < ApplicationController
  class UpdateService
    AGGREGATE_LIST_ERROR = 'Cannot manually update list items on an aggregate inventory list'

    def initialize(user, item_id, params)
      @user    = user
      @item_id = item_id
      @params  = params
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [AGGREGATE_LIST_ERROR]) if inventory_list.aggregate == true

      delta_qty = params[:quantity] ? params[:quantity].to_i - list_item.quantity : 0
      old_notes = list_item.notes

      aggregate_list_item = nil
      ActiveRecord::Base.transaction do
        list_item.update!(params)

        aggregate_list_item = aggregate_list.update_item_from_child_list(list_item.description, delta_qty, params[:unit_weight], old_notes, params[:notes])
      end

      resource = params[:unit_weight] ? all_matching_items : [aggregate_list_item, list_item]

      Service::OKResult.new(resource: resource)
    rescue ActiveRecord::RecordInvalid
      Service::UnprocessableEntityResult.new(errors: list_item.error_array)
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    end

    private

    attr_reader :user, :item_id, :params

    def aggregate_list
      @aggregate_list ||= list_item.list.aggregate_list
    end

    def inventory_list
      @inventory_list ||= list_item.list
    end

    def list_item
      @list_item ||= user.inventory_list_items.find(item_id)
    end

    def all_matching_items
      aggregate_list.game.inventory_list_items.where('description ILIKE ?', list_item.description)
    end
  end
end
