# frozen_string_literal: true

# There is always a risk with concerns that they will not ultimately provide
# the flexibility that is needed in a complex application. However, there are
# going to be a few models - InventoryList would be another one coming up - that
# will require aggregate list behaviour, which is pretty complex logically, and it
# seems reasonable not to duplicate that logic too much (or split it across too
# many classes or modules).
#
# One of the main ways that model concerns limit flexibility is by making certain
# assumptions about the database schema or methods defined in the models that
# include them. That said, here are some of those assumptions.
#
# The database schema for a Aggregatable model has a few requirements. It must
# contain the following columns:
#
#    | Column            | Type    | Constraints                 |
#    | ----------------- | ------- | --------------------------- |
#    | title             | string  | null: false                 |
#    | aggregate         | boolean | null: false, default: false |
#    | aggregate_list_id | integer |                             |
#    | game_id           | integer | null: false                 |
#
# There are a few other assumptions made:
# - There is a `#list_item_class_name` method defined. For the `ShoppingList` model,
#   this would be `'ShoppingListItem'`.
# - There is a scope on the child model class called `:index_order` that defines
#   the order in which the child models should appear. For example, `ShoppingListItem`
#   models are in descending `:updated_at` order.

module Aggregatable
  extend ActiveSupport::Concern

  class AggregateListError < StandardError; end

  included do
    belongs_to :game, touch: true
    has_many :list_items, -> { index_order }, class_name: list_item_class_name, dependent: :destroy, foreign_key: :list_id
    belongs_to :aggregate_list, class_name: to_s, optional: true
    has_many :child_lists, class_name: to_s, foreign_key: :aggregate_list_id, inverse_of: :aggregate_list

    serialize :list_items, class_name: 'Array'

    validate :one_aggregate_list_per_game,        if: :aggregate_list?
    validate :not_named_all_items,                unless: :aggregate_list?
    validate :ensure_aggregate_list_is_aggregate, unless: :aggregate_list?

    before_create :create_aggregate_list,    unless: :aggregate_list?
    before_validation :set_aggregate_list,   unless: :aggregate_list?
    before_save :abort_if_aggregate_changed
    before_save :remove_aggregate_list_id,   if: :aggregate_list?
    before_save :set_title_to_all_items,     if: :aggregate_list?
    before_destroy :abort_if_aggregate,      if: :has_child_lists?
    after_destroy :destroy_aggregate_list,   unless: -> { aggregate_list? || aggregate_has_other_children? }

    scope :aggregate_first, -> { order(aggregate: :desc) }
    scope :includes_items, -> { includes(:list_items) }

    delegate :user, to: :game
  end

  def add_item_from_child_list(item)
    raise AggregateListError.new('add_item_from_child_list method only available on aggregate lists') unless aggregate_list?

    list_items.combine_or_create!(public_list_item_attrs(item).merge('list_id' => id))
  end

  def remove_item_from_child_list(attrs)
    raise AggregateListError.new('remove_item_from_child_list method only available on aggregate lists') unless aggregate_list?

    existing_item = list_items.find_by('description ILIKE ?', attrs['description'])

    raise AggregateListError.new('item passed to remove_item_from_child_list method is not represented on the aggregate list') if existing_item.nil? || existing_item.quantity < attrs['quantity']

    if existing_item.quantity == attrs['quantity']
      existing_item.destroy!
    else
      existing_item.quantity -= attrs['quantity']
      existing_item.notes     = extract_notes(attrs['notes'], existing_item.notes)
      existing_item.save!
    end

    existing_item&.persisted? ? existing_item : nil
  end

  def update_item_from_child_list(description, delta_quantity, old_notes, new_notes)
    raise AggregateListError.new('update_item_from_child_list method only available on aggregate lists') unless aggregate_list?

    existing_item = list_items.find_by('description ILIKE ?', description)

    raise AggregateListError.new('invalid data to update aggregate list item') if existing_item.nil? || delta_quantity < (-existing_item.quantity)

    existing_item.quantity += delta_quantity
    existing_item.notes     = if old_notes.nil? && new_notes.present?
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

  def ensure_aggregate_list_is_aggregate
    errors.add(:aggregate_list, 'must be an aggregate list') if aggregate_list&.aggregate != true
  end

  def set_aggregate_list
    self.aggregate_list ||= self.class.find_or_create_by!(game: game, aggregate: true)
  end

  def create_aggregate_list
    self.class.find_or_create_by!(game: game, aggregate: true)
  end

  def set_title_to_all_items
    self.title = 'All Items'
  end

  def abort_if_aggregate_changed
    throw :abort if aggregate_changed? && !new_record?
    true
  end

  def public_list_item_attrs(item)
    private_attrs = [:id, 'id', :created_at, 'created_at', :updated_at, 'updated_at']

    item.attributes.except(*private_attrs)
  end

  def abort_if_aggregate
    throw :abort if aggregate_list?
  end

  def not_named_all_items
    errors.add(:title, 'cannot be "All Items"') if title&.downcase == 'all items'
  end

  def one_aggregate_list_per_game
    scope = self.class.where(game: game, aggregate: true)

    errors.add(:aggregate, 'can only be one list per game') if scope.count > 1 || (scope.count > 0 && scope.exclude?(self))
  end

  def remove_aggregate_list_id
    self.aggregate_list_id = nil
    true
  end

  def destroy_aggregate_list
    aggregate_list.destroy!
  end

  def list_item_class_name
    raise NotImplementedError.new('Classes including Aggregatable must implement a class method :list_item_class_name.')
  end

  def aggregate_has_other_children?
    # since this is called in an after_destroy hook, any children the
    # aggregate list still has are "other" children
    aggregate_list.child_lists.any?
  end

  def aggregate_list?
    aggregate == true
  end

  def has_child_lists?
    child_lists.any?
  end
end
