# frozen_string_literal: true

class ShoppingListItemsController < ApplicationController
  before_action :set_shopping_list_item, only: %i[update destroy]
  before_action :set_shopping_list, only: %i[create]
  # TODO: make sure list items are on lists belonging to the current user
  # TODO: prevent master list item from being edited or destroyed directly
  # TODO: create_or_combine route?

  # Error cases:
  #   * Shopping list doesn't exist
  #   * Shopping list is master list
  #   * Invalid attributes for shopping list item
  #   * Error updating items on master list
  #
  # Stuff to figure out:
  #   * What should we return data-wise to make sure the front end 
  #     gets both the new item and the update to the item on the master
  #     list? The easiest thing for the front end would be to just
  #     replace both lists.
  def create
    item = @shopping_list.shopping_list_items.new(list_item_params)

    if item.save
      master_list_item = @shopping_list.master_list.shopping_list_items.find_by_description(item.description)
      
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
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def set_shopping_list_item
    @shopping_list_item ||= ShoppingListItem.find(params[:id])
  end
end
