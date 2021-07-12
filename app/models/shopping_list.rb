# frozen_string_literal: true

require 'titlecase'

class ShoppingList < ApplicationRecord
  # Titles have to be unique per user as described in the API docs. They also can only
  # contain alphanumeric characters and spaces with no special characters or whitespace
  # other than spaces. Leading or trailing whitespace is stripped anyway so the validation
  # ignores any leading or trailing whitespace characters.
  validates :title, uniqueness: { scope: :user_id },
                    format: {
                      with: /\A\s*[a-z0-9 ]*\s*\z/i,
                      message: 'can only include alphanumeric characters and spaces'
                    }

  before_save :format_title

  # This has to be defined before including AggregateListable because its `included` block
  # calls this method.
  def self.list_item_class_name
    'ShoppingListItem'
  end

  include Aggregatable

  scope :index_order, -> { includes_items.aggregate_first.order(updated_at: :desc) }

  private

  def format_title
    return if aggregate

    if title.blank?
      highest_number = user.shopping_lists.where("title like '%My List%'").pluck(:title).map { |title| title.gsub('My List ', '').to_i }.max || 0
      self.title = "My List #{highest_number + 1}"
    else
      self.title = Titlecase.titleize(title.strip)
    end
  end
end
