# frozen_string_literal: true

class ShoppingListsController < ApplicationController
  def index
    render json: current_user.shopping_lists, status: :ok
  end

  def create
    shopping_list = current_user.shopping_lists.new

    if shopping_list.save
      render json: shopping_list, status: :created
    else
      head :unprocessable_entity
    end
  end

  def show
    shopping_list = current_user.shopping_lists.find(params[:id])

    render json: shopping_list, status: :ok
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def destroy
    shopping_list = current_user.shopping_lists.find(params[:id])
    shopping_list.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
