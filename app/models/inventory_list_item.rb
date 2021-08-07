# frozen_string_literal: true

class InventoryListItem < ApplicationRecord
  belongs_to :list, class_name: 'InventoryList', touch: true

  delegate :game, :user, to: :list

  scope :index_order, -> { order(updated_at: :desc) }
end
