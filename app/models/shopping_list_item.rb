# frozen_string_literal: true

class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list

  validates :description, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  before_save :humanize_description
  before_update :prevent_changed_description
  after_create :add_to_master_list, unless: :shopping_list_is_master_list?
  after_update :adjust_master_list_after_update, unless: :shopping_list_is_master_list?
  after_destroy :adjust_master_list_after_destroy, unless: :shopping_list_is_master_list?

  delegate :user, to: :shopping_list

  def self.create_or_combine!(attrs)
    list = attrs[:shopping_list] || ShoppingList.find(attrs[:shopping_list_id])
    desc = (attrs[:description] || attrs['description'])&.humanize
    existing_item = list.shopping_list_items.find_by_description(desc)

    if existing_item.nil?
      create!(attrs)
    else
      qty = attrs[:quantity] || attrs['quantity'] || 1
      new_quantity = existing_item.quantity + qty
      existing_item.update!(quantity: new_quantity)
    end
  end

  private

  def add_to_master_list
    new_attrs = self.attributes.reject { |key, value| ['shopping_list_id', :shopping_list_id, 'id', :id].include?(key) }
    ShoppingListItem.create_or_combine!(**new_attrs, shopping_list: master_list)
  end

  def adjust_master_list_after_update
    # Any item being updated (as opposed to created) will already be represented on the master list.
    # So we just need to find the item on the master list and add delta_quantity to its quantity value.
    # The new value will never be zero because there will be a validation error before saving if the
    # new quantity value is zero. On the client side, when a user enters a quantity of zero, the client
    # should implement logic to make a DELETE request on the list item instead.
    delta_quantity = saved_change_to_attribute(:quantity).last - saved_change_to_attribute(:quantity).first
    item_on_master_list = master_list.shopping_list_items.find_by_description(description)
    item_on_master_list.update!(quantity: item_on_master_list.quantity + delta_quantity)
  end

  def adjust_master_list_after_destroy
    item_on_master_list = master_list.shopping_list_items.find_by_description(description)

    if item_on_master_list.quantity == quantity
      item_on_master_list.destroy!
    else
      item_on_master_list.update!(quantity: item_on_master_list.quantity - quantity)
    end
  end

  def prevent_changed_description
    return true if new_record?
    throw :abort if description_changed?
  end

  def humanize_description
    self.description = description.humanize
  end

  def shopping_list_is_master_list?
    self.shopping_list.master == true
  end

  def master_list
    @master_list ||= user.master_shopping_list
  end
end
