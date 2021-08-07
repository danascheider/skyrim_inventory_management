# frozen_string_literal: true

class InventoryList < ApplicationRecord
  # This has to be defined before including AggregateListable because its `included` block
  # calls this method.
  def self.list_item_class_name
    'InventoryListItem'
  end

  include Aggregatable

  scope :index_order, -> { includes_items.aggregate_first.order(updated_at: :desc) }
  scope :belonging_to_user, ->(user) { joins(:game).where(games: { user_id: user.id }).order('inventory_lists.updated_at DESC') }
end
