# frozen_string_literal: true

class InventoryList < ApplicationRecord
  # Titles have to be unique per game as described in the API docs. They also can only
  # contain alphanumeric characters and spaces with no special characters or whitespace
  # other than spaces. Leading or trailing whitespace is stripped anyway so the validation
  # ignores any leading or trailing whitespace characters.
  validates :title,
            uniqueness: { scope: :game_id, message: 'must be unique per game', case_sensitive: false },
            format:     {
                          with:    /\A\s*[a-z0-9 \-',]*\s*\z/i,
                          message: "can only contain alphanumeric characters, spaces, commas (,), hyphens (-), and apostrophes (')",
                        }

  # This has to be defined before including AggregateListable because its `included` block
  # calls this method.
  def self.list_item_class_name
    'InventoryListItem'
  end

  include Aggregatable

  scope :index_order, -> { includes_items.aggregate_first.order(updated_at: :desc) }
  scope :belonging_to_user, ->(user) { joins(:game).where(games: { user_id: user.id }).order('inventory_lists.updated_at DESC') }
end
