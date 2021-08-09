# frozen_string_literal: true

require 'controller/response'

class InventoryListsController < ApplicationController
  def index
    result = IndexService.new(current_user, params[:game_id]).perform

    ::Controller::Response.new(self, result).execute
  end
end
