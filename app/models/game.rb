# frozen_string_literal: true

require 'titlecase'

class Game < ApplicationRecord
  belongs_to :user
  has_many :shopping_lists, dependent: :destroy

  validates :name, uniqueness: { scope: :user_id },
                   format: {
                     with: /\A\s*[a-z0-9 '\,]*\s*\z/i,
                     message: "can only contain alphanumeric characters, spaces, commas (,), and apostrophes (')"
                   }

  before_save :format_name

  def aggregate_shopping_list
    shopping_lists.find_by(aggregate: true)
  end

  private

  def format_name
    if name.blank?
      highest_number = user.games.where("name like '%My Game%'").pluck(:name).map { |n| n.gsub('My Game ', '').to_i }.max || 0
      self.name = "My Game #{highest_number + 1}"
    else
      self.name = Titlecase.titleize(name.strip)
    end
  end
end
