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
end
