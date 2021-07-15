# frozen_string_literal: true

require 'service/ok_result'
require 'service/not_found_result'
require 'service/internal_server_error_result'

class ShoppingListsController < ApplicationController
  class IndexService
    def initialize(user, game_id)
      @user = user
      @game_id = game_id
    end

    def perform
      Service::OKResult.new(resource: game.shopping_lists.index_order)
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new
    rescue => e
      Rails.logger.error "Internal Server Error: #{e.message}"
      Service::InternalServerErrorResult.new(errors: [e.message])
    end

    private

    attr_reader :user, :game_id

    def game
      user.games.find(game_id)
    end
  end
end
