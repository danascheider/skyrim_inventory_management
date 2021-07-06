# frozen_string_literal: true

class ShoppingListItem < ApplicationRecord
  belongs_to :list, class_name: 'ShoppingList'

  validates :description, presence: true, uniqueness: { scope: :list_id }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :prevent_changed_description, on: :update

  before_save :humanize_description
  before_save :clean_up_notes

  delegate :user, to: :list

  scope :index_order, -> { order(updated_at: :desc) }
  scope :belonging_to_user, ->(user) { joins(:list).where('shopping_lists.user_id = ?', user.id).order('shopping_lists.updated_at DESC') }

  def self.combine_or_create!(attrs)
    obj = combine_or_new(attrs)
    obj.save!
    obj
  end

  def self.combine_or_new(attrs)
    shopping_list = attrs[:list] || attrs['list'] || ShoppingList.find(attrs[:list_id] || attrs['list_id'])
    desc = (attrs[:description] || attrs['description'])&.humanize
    existing_item = shopping_list.list_items.find_by_description(desc)

    if existing_item.nil?
      new attrs
    else
      qty = attrs[:quantity] || attrs['quantity'] || 1
      new_notes = attrs[:notes] || attrs['notes']
      old_notes = existing_item.notes

      new_quantity = existing_item.quantity + qty
      new_notes = [old_notes, new_notes].compact.join(' -- ').presence

      existing_item.assign_attributes(quantity: new_quantity, notes: new_notes)
      existing_item
    end
  end

  private

  def prevent_changed_description
    errors.add(:description, 'cannot be updated on an existing list item') if description_changed?
  end

  def humanize_description
    self.description = description.humanize
  end

  def clean_up_notes
    return true unless notes
    self.notes = notes.strip.gsub(/^(\-\- )*/, '').gsub(/( \-\-)*$/, '').gsub(/( \-\- ){2,}/, ' -- ')
  end
end
