# frozen_string_literal: true

require 'titlecase'

class Game < ApplicationRecord
  belongs_to :user
  has_many :shopping_lists, -> { index_order }, dependent: :destroy, inverse_of: :game

  validates :name,
            uniqueness: { scope: :user_id, message: 'must be unique' },
            format:     {
                          with:    /\A\s*[a-z0-9 \-',]*\s*\z/i,
                          message: "can only contain alphanumeric characters, spaces, commas (,), hyphens (-), and apostrophes (')",
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
      max_existing_number = user.games.where("name LIKE 'My Game %'").pluck(:name).map {|t| t.gsub('My Game ', '').to_i }
                              .max || 0
      next_number         = max_existing_number >= 0 ? max_existing_number + 1 : 1
      self.name           = "My Game #{next_number}"
    else
      self.name = Titlecase.titleize(name.strip)
    end
  end
end
