# frozen_string_literal: true

require 'service/created_result'
require 'service/ok_result'
require 'service/not_found_result'
require 'service/unprocessable_entity_result'
require 'service/method_not_allowed_result'
require 'service/internal_server_error_result'

class InventoryListItemsController < ApplicationController
  class CreateService
    AGGREGATE_LIST_ERROR = 'Cannot manually manage items on an aggregate inventory list'

    def initialize(user, list_id, params)
      @user    = user
      @list_id = list_id
      @params  = params
    end

    def perform
      return Service::MethodNotAllowedResult.new(errors: [AGGREGATE_LIST_ERROR]) if inventory_list.aggregate == true

      preexisting_item = inventory_list.list_items.find_by('description ILIKE ?', params[:description])
      item             = InventoryListItem.combine_or_new(params.merge(list_id: list_id))

      ActiveRecord::Base.transaction do
        item.save!

        if preexisting_item.blank?
          aggregate_list_item = aggregate_list.add_item_from_child_list(item)

          resource = params[:unit_weight] ? all_matching_list_items : [aggregate_list_item, item]
          Service::CreatedResult.new(resource: resource)
        else
          aggregate_list_item = aggregate_list.update_item_from_child_list(params[:description], params[:quantity], params[:unit_weight], nil, params[:notese])

          resource = params[:unit_weight] ? all_matching_list_items : [aggregate_list_item, item]

          Service::OKResult.new(resource: resource)
        end
      end
    rescue ActiveRecord::RecordInvalid
      Service::UnprocessableEntityResult.new(errors: item.error_array)
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    rescue StandardError => e
      Service::InternalServerErrorResult.new(errors: e.message)
    end

    private

    attr_reader :user, :list_id, :params

    def inventory_list
      @inventory_list ||= user.inventory_lists.find(list_id)
    end

    def aggregate_list
      @aggregate_list ||= inventory_list.aggregate_list
    end

    def all_matching_list_items
      aggregate_list.game.inventory_list_items.where('description ILIKE ?', params[:description])
    end
  end
end