# frozen_string_literal: true

require 'controller/response'

class ShoppingListItemsController < ApplicationController
  before_action :set_shopping_list_item, only: %i[destroy]

  def create
    result = CreateService.new(current_user, params[:shopping_list_id], list_item_params).perform

    ::Controller::Response.new(self, result).execute
  end

  def update
    result = UpdateService.new(current_user, params[:id], list_item_params).perform

    ::Controller::Response.new(self, result).execute
  end

  private

  def list_item_params
    params.require(:shopping_list_item).permit(
      :description,
      :quantity,
      :notes
    )
  end

  def set_shopping_list_item
    @shopping_list_item ||= ShoppingListItem.find(params[:id])
  end
end
