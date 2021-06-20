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
    shopping_list = attrs[:shopping_list] || ShoppingList.find(attrs[:shopping_list_id])
    desc = (attrs[:description] || attrs['description'])&.humanize
    existing_item = shopping_list.shopping_list_items.find_by_description(desc)

    if existing_item.nil?
      create!(attrs)
    else
      qty = attrs[:quantity] || attrs['quantity'] || 1
      notes = attrs[:notes] || attrs['notes']

      new_quantity = existing_item.quantity + qty
      new_notes = [existing_item.notes, notes].join(' -- ')

      existing_item.update!(quantity: new_quantity, notes: new_notes)
    end
  end

  private

  def add_to_master_list
    new_attrs = reject_non_public_attrs(self.attributes)
    ShoppingListItem.create_or_combine!(**new_attrs, shopping_list: master_list)
  end

  def adjust_master_list_after_update
    # Any item being updated (as opposed to created) will already be represented on the master list.
    # So we just need to find the item on the master list and add delta_quantity to its quantity value.
    # The new value will never be zero because there will be a validation error before saving if the
    # new quantity value is zero. On the client side, when a user enters a quantity of zero, the client
    # should implement logic to make a DELETE request on the list item instead.
    item_on_master_list = master_list.shopping_list_items.find_by_description(description)

    item_on_master_list.update!(
      quantity: item_on_master_list.quantity + delta_quantity,
      notes: update_combined_note_values(item_on_master_list.notes, *saved_change_to_attribute(:notes))
    )
  end

  def adjust_master_list_after_destroy
    item_on_master_list = master_list.shopping_list_items.find_by_description(description)

    item_on_master_list.destroy! && return if item_on_master_list.quantity == quantity

    if notes.present?
      new_notes = item_on_master_list.notes.sub(/#{notes}/, '').gsub(/^ ?\-\- /, '').gsub(/ \-\- ?$/, '')
    end

    new_notes = nil unless defined?(new_notes) && new_notes.present?

    item_on_master_list.update!(
      quantity: item_on_master_list.quantity - quantity,
      notes: new_notes || item_on_master_list.notes
    )
  end

  def prevent_changed_description
    throw :abort if description_changed?
  end

  def humanize_description
    self.description = description.humanize
  end

  def shopping_list_is_master_list?
    self.shopping_list.master == true
  end

  def delta_quantity
    saved_change_to_attribute(:quantity).present? ? 
      saved_change_to_attribute(:quantity).last - saved_change_to_attribute(:quantity).first :
      0
  end

  # When updating the notes on a regular list item, we also want to update
  # the value on the corresponding master list. The issue is that the notes
  # on a master list item consists of the combined notes fields of all regular
  # list items matching that description. We only want to update the note
  # that's being changed.
  #
  # All args to this method are strings. "combined_value" is the existing
  # value of the notes on the master list. "old_value" is the original value
  # of the note being changed, and "new_value" is the new value. The "notes"
  # field of the master list item is set to the returned value in the
  # #adjust_master_list_after_update method.
  #
  def update_combined_note_values(combined_value = nil, old_value = nil, new_value = nil)
    return new_value unless combined_value.present?

    if old_value.present? && combined_value =~ /#{old_value}/
      combined_value.sub(old_value, new_value.to_s).gsub(/^ ?\-\- /, '').gsub(/ \-\- ?$/, '')
    elsif old_value.blank?
      [combined_value, new_value].join(' -- ').gsub(/^ ?\-\- /, '').gsub(/ \-\- ?$/, '')
    end
  end

  def master_list
    @master_list ||= user.master_shopping_list
  end

  def reject_non_public_attrs(attrs)
    non_public_attrs = [:id, 'id', :shopping_list_id, 'shopping_list_id', :created_at, 'created_at', :updated_at, 'updated_at']
    attrs.reject { |key, value| non_public_attrs.include?(key) }
  end
end
