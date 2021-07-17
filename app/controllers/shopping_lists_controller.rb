# frozen_string_literal: true

require 'controller/response'

class ShoppingListsController < ApplicationController
  def index
    result = IndexService.new(current_user, params[:game_id]).perform

    ::Controller::Response.new(self, result).execute
  end

  def create
    result = CreateService.new(current_user, params[:game_id], shopping_list_params).perform

    ::Controller::Response.new(self, result).execute
  end

  def update
    result = UpdateService.new(current_user, params[:id], shopping_list_params).perform

    ::Controller::Response.new(self, result).execute
  end

  def destroy
    result = DestroyService.new(current_user, params[:id]).perform

    ::Controller::Response.new(self, result).execute
  end

  private

  def shopping_list_params
    params[:shopping_list].present? ? params.require(:shopping_list).permit(:title, :aggregate) : {}
  end
end
