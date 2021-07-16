# frozen_string_literal: true

require 'titlecase'

class Game < ApplicationRecord
  belongs_to :user
  has_many :shopping_lists, -> { index_order }, dependent: :destroy

  validates :name, uniqueness: { scope: :user_id, message: 'must be unique' },
                   format: {
                     with: /\A\s*[a-z0-9 \-'\,]*\s*\z/i,
                     message: "can only contain alphanumeric characters, spaces, commas (,), hyphens (-), and apostrophes (')"
                   }

  before_save :format_name

  scope :index_order, -> { order(updated_at: :desc) }

  def aggregate_shopping_list
    shopping_lists.find_by(aggregate: true)
  end

  def shopping_list_items
    ShoppingListItem.belonging_to_game(self)
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
