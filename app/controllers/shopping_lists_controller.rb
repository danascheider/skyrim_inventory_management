# frozen_string_literal: true

require 'controller/response'

class ShoppingListsController < ApplicationController
  before_action :set_shopping_list, only: %i[show update destroy]
  before_action :prevent_setting_master, only: %i[create update]
  before_action :prevent_update_master_list, only: :update
  before_action :prevent_destroy_master_list, only: :destroy

  def index
    result = IndexService.new(current_user).perform

    ::Controller::Response.new(self, result).execute
  end

  def create
    shopping_list = current_user.shopping_lists.new(shopping_list_params)

    if shopping_list.save
      resp_body = [shopping_list]

      if (shopping_list.created_at - current_user.master_shopping_list.created_at).abs < 1.second
        resp_body.unshift(current_user.master_shopping_list)
      end

      render json: resp_body, status: :created
    else
      render json: { errors: shopping_list.errors }, status: :unprocessable_entity
    end
  end

  def show
    render json: @shopping_list, status: :ok
  end

  def update
    if @shopping_list.update(shopping_list_params)
      render json: @shopping_list, status: :ok
    else
      render json: { errors: @shopping_list.errors }, status: :unprocessable_entity
    end
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

  def prevent_setting_master
    if shopping_list_params.fetch(:master, nil) == true
      render json: { errors: { master: ['cannot manually create or update a master shopping list'] } }, status: :unprocessable_entity
    end
  end

  def prevent_update_master_list
    if @shopping_list.master == true
      render json: { error: 'Cannot manually update a master shopping list' }, status: :method_not_allowed
    end
  end

  def prevent_destroy_master_list
    if @shopping_list.master == true
      render json: { error: 'Cannot manually destroy a master shopping list' }, status: :method_not_allowed
    end
  end
end
