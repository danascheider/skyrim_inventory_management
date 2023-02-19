# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_create :assign_user

  def error_array
    errors.map {|error| "#{error.attribute.capitalize} #{error.message}" }
  end

  private

  def assign_user
    return unless respond_to?(:user=)

    self.user = User.first
  end
end
