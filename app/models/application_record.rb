# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def error_array
    errors.map {|error| "#{error.attribute.capitalize} #{error.message}" }
  end
end
