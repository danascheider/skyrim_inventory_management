# frozen_string_literal: true

class InventoryListItem < ApplicationRecord
  belongs_to :list, class_name: 'InventoryList', touch: true

  validates :description, presence: true, uniqueness: { scope: :list_id, case_sensitive: false }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validate :prevent_changed_description, on: :update

  before_save :clean_up_notes

  delegate :game, :user, to: :list

  scope :index_order, -> { order(updated_at: :desc) }
  scope :belonging_to_game, ->(game) { joins(:list).where(inventory_lists: { game_id: game.id }).order('inventory_lists.updated_at DESC') }

  def self.belonging_to_user(user)
    inventory_list_ids = InventoryList.belonging_to_user(user).ids
    joins(:list).where(inventory_lists: { id: inventory_list_ids }).order('inventory_lists.updated_at DESC')
  end

  def self.combine_or_create!(attrs)
    obj = combine_or_new(attrs)
    obj.save!
    obj
  end

  def self.combine_or_new(attrs)
    inventory_list = attrs[:list] || attrs['list'] || InventoryList.find(attrs[:list_id] || attrs['list_id'])
    desc           = (attrs[:description] || attrs['description'])
    existing_item  = inventory_list.list_items.find_by('description ILIKE ?', desc)

    if existing_item.nil?
      new attrs
    else
      qty       = attrs[:quantity] || attrs['quantity'] || 1
      new_notes = attrs[:notes] || attrs['notes']
      old_notes = existing_item.notes

      new_quantity = existing_item.quantity + qty
      new_notes    = [old_notes, new_notes].compact.join(' -- ').presence

      existing_item.assign_attributes(quantity: new_quantity, notes: new_notes)
      existing_item
    end
  end

  private

  def prevent_changed_description
    errors.add(:description, 'cannot be updated on an existing list item') if description_changed?
  end

  def clean_up_notes
    return true unless notes

    self.notes = notes.strip.gsub(/^(-- ?)*/, '').gsub(/( ?--)*$/, '').gsub(/( -- ){2,}/, ' -- ').presence
  end
end
