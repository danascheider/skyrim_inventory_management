# frozen_string_literal: true

require 'service/ok_result'

class ShoppingListsController < ApplicationController
  class IndexService
    def initialize(user)
      @user = user
    end

    def perform
      Service::OKResult.new(resource: user.shopping_lists.index_order)
    end

    private

    attr_reader :user
  end
end
