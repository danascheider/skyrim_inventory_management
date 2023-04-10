# frozen_string_literal: true

namespace :one_off do
  desc 'Remove notes values from aggregate list items'
  task remove_notes_from_aggregate_list_items: :environment do
    ShoppingListItem
      .joins(:list)
      .where(shopping_lists: { aggregate: true })
      .each {|item| item.update(notes: nil) }

    InventoryItem
      .joins(:list)
      .where(inventory_lists: { aggregate: true })
      .each {|item| item.update(notes: nil) }
  end
end
