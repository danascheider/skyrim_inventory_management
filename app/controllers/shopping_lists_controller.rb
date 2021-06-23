# frozen_string_literal: true

class ShoppingListsController < ApplicationController
  before_action :set_shopping_list, only: %i[show update destroy]
  before_action :prevent_action_on_master_list, only: %i[create update]
  before_action :prevent_destroy_master_list, only: :destroy

  def index
    render json: current_user.shopping_lists.master_first.to_json(include: :shopping_list_items), status: :ok
  end

  def create
    shopping_list = current_user.shopping_lists.new(shopping_list_create_params)

    if shopping_list.save
      render json: shopping_list, status: :created
    else
      render json: { errors: shopping_list.errors }, status: :unprocessable_entity
    end
  end

  def show
    render json: @shopping_list, status: :ok
  end

  def update
    if @shopping_list.update(shopping_list_update_params)
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

  def shopping_list_create_params
    params[:shopping_list].present? ? params.require(:shopping_list).permit(:title) : {}
  end
  
  def shopping_list_update_params
    params.require(:shopping_list).permit(:title)
  end

  def set_shopping_list
    @shopping_list = current_user.shopping_lists.includes(:shopping_list_items).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def prevent_action_on_master_list
    if @shopping_list&.master == true || params[:shopping_list]&.fetch(:master, nil) == true
      render json: { errors: { master: ['cannot create or update a master shopping list through the API'] } }, status: :unprocessable_entity
    end
  end

  def prevent_destroy_master_list
    if @shopping_list.master == true
      render json: { error: 'cannot destroy a master shopping list through the API' }, status: :method_not_allowed
    end
  end
end
