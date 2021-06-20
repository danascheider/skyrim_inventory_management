# frozen_string_literal: true

class ShoppingListsController < ApplicationController
  def index
    render json: current_user.shopping_lists.to_json(include: :shopping_list_items), status: :ok
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
    shopping_list = current_user.shopping_lists.includes(:shopping_list_items).find(params[:id])

    render json: shopping_list, status: :ok
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def update
    shopping_list = current_user.shopping_lists.find(params[:id])

    if shopping_list.update(shopping_list_update_params)
      render json: shopping_list, status: :ok
    else
      render json: { errors: shopping_list.errors }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def destroy
    shopping_list = current_user.shopping_lists.find(params[:id])

    if shopping_list.master
      if current_user.shopping_lists.count == 1 # if they don't have other lists allow it
        shopping_list.destroy!
        head :no_content
      else
        head :method_not_allowed
      end
    else
      shopping_list.destroy!
      if current_user.master_shopping_list.present? # if this was their last regular list the master will have been destroyed
        render json: { master_list: current_user.master_shopping_list }, status: :ok
      else
        head :no_content
      end
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

  def shopping_list_create_params
    params[:shopping_list].present? ? params.require(:shopping_list).permit(:title) : {}
  end
  
  def shopping_list_update_params
    params.require(:shopping_list).permit(:title)
  end
end
