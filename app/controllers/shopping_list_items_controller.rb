# frozen_string_literal: true

class ShoppingListItemsController < ApplicationController
  before_action :set_shopping_list_item, only: %i[update destroy]
  before_action :set_shopping_list, only: %i[create]

  def create
    item = @shopping_list.shopping_list_items.combine_or_new(list_item_params)

    if item.save
      master_list_item = @shopping_list.master_list.shopping_list_items.find_by_description(item.description)

      @shopping_list.touch
      
      render json: [master_list_item, item], status: :created
    else
      render json: { errors: item.errors }, status: :unprocessable_entity
    end
  end

  private

  def list_item_params
    params.require(:shopping_list_item).permit(
      :description,
      :quantity,
      :notes,
      :shopping_list_id
    )
  end

  def set_shopping_list
    @shopping_list ||= current_user.shopping_lists.find(params[:shopping_list_id])

    render json: { error: 'Cannot manage master shopping list items directly.' }, status: :method_not_allowed if @shopping_list.master
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def set_shopping_list_item
    @shopping_list_item ||= ShoppingListItem.find(params[:id])
  end
end
