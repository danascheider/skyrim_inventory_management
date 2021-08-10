# frozen_string_literal: true

require 'controller/response'

class InventoryListItemsController < ApplicationController
  def create
    result = CreateService.new(current_user, params[:inventory_list_id], inventory_list_item_params).perform

    ::Controller::Response.new(self, result).execute
  end

  private

  def inventory_list_item_params
    params.require(:inventory_list_item).permit(:description, :quantity, :notes, :unit_weight)
  end
end
