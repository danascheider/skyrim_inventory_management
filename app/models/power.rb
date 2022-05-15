# frozen_string_literal: true

class Power < ApplicationRecord
  validates :name, presence: true, uniqueness: { message: 'must be unique' }
  validates :power_type,
            presence:  true,
            inclusion: {
                         in:      %w[greater lesser ability],
                         message: 'must be "greater", "lesser", or "ability"',
                       }
  validates :source, presence: true
  validates :description, presence: true

  def self.unique_identifier
    :name
  end
end
