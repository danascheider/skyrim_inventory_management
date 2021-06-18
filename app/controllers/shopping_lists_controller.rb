# frozen_string_literal: true

class ShoppingListsController < ApplicationController
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
end
