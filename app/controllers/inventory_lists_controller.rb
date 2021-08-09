# frozen_string_literal: true

require 'controller/response'

class InventoryListsController < ApplicationController
  def index
    result = IndexService.new(current_user, params[:game_id]).perform

    ::Controller::Response.new(self, result).execute
  end

  def create
    result = CreateService.new(current_user, params[:game_id], inventory_list_params).perform

    ::Controller::Response.new(self, result).execute
  end

  private

  def inventory_list_params
    params[:inventory_list].present? ? params.require(:inventory_list).permit(:title, :aggregate) : {}
  end
end
