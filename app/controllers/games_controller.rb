# frozen_string_literal: true

require 'controller/response'

class GamesController < ApplicationController
  def create
    result = CreateService.new(current_user, game_params).perform

    ::Controller::Response.new(self, result).execute
  end

  private

  def game_params
    params.require(:game).permit(:name, :description)
  end
end
