# frozen_string_literal: true

require 'service/ok_result'

class UsersController < ApplicationController
  class ShowService
    def initialize(user)
      @user = user
    end

    def perform
      Service::OKResult.new(resource: user)
    end

    private

    attr_reader :user
  end
end
