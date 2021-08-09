# frozen_string_literal: true

require 'service/ok_result'

class InventoryListsController < ApplicationController
  class UpdateService
    def initialize(user, list_id, params)
      @user    = user
      @list_id = list_id
      @params  = params
    end

    def perform
      inventory_list.update!(params)
      Service::OKResult.new(resource: inventory_list)
    end

    private

    attr_reader :user, :list_id, :params

    def inventory_list
      @inventory_list ||= InventoryList.find(list_id)
    end
  end
end
