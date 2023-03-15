# frozen_string_literal: true

require 'service/created_result'
require 'service/unprocessable_entity_result'
require 'service/not_found_result'
require 'service/method_not_allowed_result'
require 'service/internal_server_error_result'
require 'service/ok_result'

class ShoppingListsController < ApplicationController
  class CreateService
    AGGREGATE_LIST_ERROR = 'Cannot manually create an aggregate shopping list'

    def initialize(user, game_id, params)
      @user = user
      @game_id = game_id
      @params = params
    end

    def perform
      return Service::UnprocessableEntityResult.new(errors: [AGGREGATE_LIST_ERROR]) if params[:aggregate]

      shopping_list = game.shopping_lists.new(params)

      if shopping_list.save
        Service::CreatedResult.new(resource: game.shopping_lists.index_order)
      else
        Service::UnprocessableEntityResult.new(errors: shopping_list.error_array)
      end
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    rescue StandardError => e
      Rails.logger.error "Internal Server Error: #{e.message}"
      Service::InternalServerErrorResult.new(errors: [e.message])
    end

    private

    attr_reader :user, :game_id, :params

    def game
      user.games.find(game_id)
    end
  end
end
