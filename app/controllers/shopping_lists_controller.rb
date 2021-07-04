# frozen_string_literal: true

require 'controller/response'

class ShoppingListsController < ApplicationController
  before_action :set_shopping_list, only: %i[destroy]
  before_action :prevent_destroy_master_list, only: :destroy

  def index
    result = IndexService.new(current_user).perform

    ::Controller::Response.new(self, result).execute
  end

  def create
    result = CreateService.new(current_user, shopping_list_params).perform

    ::Controller::Response.new(self, result).execute
  end

  def update
    result = UpdateService.new(current_user, params[:id], shopping_list_params).perform
    
    ::Controller::Response.new(self, result).execute
  end

  def destroy
    @shopping_list.destroy!
    if current_user.master_shopping_list.present? # if this was their last regular list the master will have been destroyed
      render json: { master_list: current_user.master_shopping_list }, status: :ok
    else
      head :no_content
    end
  end

  private

  def shopping_list_params
    params[:shopping_list].present? ? params.require(:shopping_list).permit(:title, :master) : {}
  end

  def set_shopping_list
    @shopping_list = current_user.shopping_lists.includes(:shopping_list_items).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Shopping list id=#{params[:id]} not found"}, status: :not_found
  end

  def prevent_destroy_master_list
    if @shopping_list.master == true
      render json: { error: 'Cannot manually destroy a master shopping list' }, status: :method_not_allowed
    end
  end
end
