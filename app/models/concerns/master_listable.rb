# frozen_string_literal: true

# There is always a risk with concerns that they will not ultimately provide
# the flexibility that is needed in a complex application. However, there are
# going to be a few models - InventoryList would be another one coming up - that
# will require master list behaviour, which is pretty complex logically, and it
# seems reasonable not to duplicate that logic too much (or split it across too
# many classes or modules).
#
# One of the main ways that model concerns limit flexibility is by making certain
# assumptions about the database schema or methods defined in the models that
# include them. That said, here are some of those assumptions.
#
# The database schema for a MasterListable model has a few requirements. It must
# contain the following columns:
# 
#    | Column         | Type    | Constraints                 |
#    | -------------- | ------- | --------------------------- |
#    | title          | string  | null: false                 |
#    | master         | boolean | null: false, default: false |
#    | master_list_id | integer |                             |
#    | user_id        | integer | null: false                 |
#
# There are a few other assumptions made:
# - There is a `#list_item_class_name` method defined. For a `ShoppingList` model,
#   this would be `'ShoppingListItem'`.
# - There is a scope on the child model class called `:index_order` that defines
#   the order in which the child models should appear. For example, `ShoppingListItem`
#   models are in descending `:updated_at` order.

module MasterListable
  extend ActiveSupport::Concern

  class MasterListError < StandardError; end
  
  included do
    belongs_to :user
    has_many :list_items, -> { index_order }, class_name: self.list_item_class_name, dependent: :destroy, foreign_key: :list_id
    belongs_to :master_list, class_name: self.to_s, foreign_key: :master_list_id, optional: true
    has_many :child_lists, class_name: self.to_s, foreign_key: :master_list_id, inverse_of: :master_list

    scope :master_first, -> { order(master: :desc) }
    scope :includes_items, -> { includes(:list_items) }

    validate :one_master_list_per_user,     if: :is_master_list?
    validate :not_named_master,             unless: :is_master_list?
    validate :ensure_master_list_is_master, unless: :is_master_list?

    before_create :create_master_list,    unless: :is_master_list?
    before_validation :set_master_list,   unless: :is_master_list?
    before_save :abort_if_master_changed
    before_save :remove_master_list_id,   if: :is_master_list?
    before_save :set_title_to_master,     if: :is_master_list?
    before_destroy :abort_if_master,      if: :has_child_lists?
    after_destroy :destroy_master_list,   unless: -> { is_master_list? || master_has_other_children? }
  end

  def add_item_from_child_list(item)
    raise MasterListError, 'add_item_from_child_list method only available on master lists' unless is_master_list?

    list_items.combine_or_create!(public_list_item_attrs(item).merge('list_id' => id))
  end

  def remove_item_from_child_list(attrs)
    raise MasterListError, 'remove_item_from_child_list method only available on master lists' unless is_master_list?

    existing_item = list_items.find_by(description: attrs['description'])

    if existing_item.nil? || existing_item.quantity < attrs['quantity']
      raise MasterListError, 'item passed to remove_item_from_child_list method is not represented on the master list'
    end

    if existing_item.quantity == attrs['quantity']
      existing_item.destroy!
    else
      existing_item.quantity -= attrs['quantity']
      existing_item.notes = extract_notes(attrs['notes'], existing_item.notes)
      existing_item.save!
    end

    existing_item&.persisted? ? existing_item : nil
  end

  def update_item_from_child_list(description, delta_quantity, old_notes, new_notes)
    raise MasterListError, 'update_item_from_child_list method only available on master lists' unless is_master_list?

    existing_item = list_items.find_by(description: description)

    if existing_item.nil? || delta_quantity < (-existing_item.quantity)
      raise MasterListError, 'invalid data to update master list item'
    end

    existing_item.quantity += delta_quantity
    existing_item.notes = if old_notes.nil? && new_notes.present?
                            [existing_item.notes.to_s, new_notes.to_s].join(' -- ')
                          else
                            existing_item.notes&.sub(/#{old_notes}/, new_notes.to_s).presence || new_notes
                          end

    existing_item.save!
    existing_item
  end

  def extract_notes(notes, existing)
    return existing unless notes && existing.to_s =~ /#{notes}/

    existing.sub(notes, '')
  end

  def ensure_master_list_is_master
    if master_list&.master != true
      errors.add(:master_list, 'must be a master list')
    end
  end

  def set_master_list
    self.master_list ||= self.class.find_or_create_by!(user: user, master: true)
  end

  def create_master_list
    self.class.find_or_create_by!(user: user, master: true)
  end

  def set_title_to_master
    self.title = 'Master'
  end

  def abort_if_master_changed
    throw :abort if master_changed? && !new_record?
    true
  end

  def public_list_item_attrs(item)
    private_attrs = [:id, 'id', :created_at, 'created_at', :updated_at, 'updated_at']

    item.attributes.reject { |key, value| private_attrs.include?(key) }
  end

  def abort_if_master
    throw :abort if is_master_list?
  end

  def not_named_master
    errors.add(:title, 'cannot be "Master"') if title&.downcase == 'master'
  end

  def one_master_list_per_user
    scope = self.class.where(user: user, master: true)

    if scope.count > 1 || (scope.count > 0 && !scope.include?(self))
      errors.add(:master, 'can only be one list per user')
    end
  end

  def remove_master_list_id
    self.master_list_id = nil
    true
  end

  def destroy_master_list
    master_list.destroy!
  end

  def list_item_class_name
    raise NotImplementedError, 'Classes including MasterListable must implement a class method :list_item_class_name.'
  end

  def master_has_other_children?
    # since this is called in an after_destroy hook, any children the
    # master list still has are "other" children
    master_list.child_lists.any?
  end

  def is_master_list?
    master == true
  end

  def has_child_lists?
    child_lists.any?
  end
end
