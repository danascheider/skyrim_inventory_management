# Aggregate Lists

## Contents

* [Overview](#overview)
* [Glossary](#glossary)
* [Database and ORM Requirements](#database-and-orm-requirements)
* [Aggregate List Behaviour](#aggregate-list-behaviour)
  * [Creation and Destruction of Aggregate Lists](#creation-and-destruction-of-aggregate-lists)
  * [Updating Aggregate Lists](#updating-aggregate-lists)
    * [Adding an Item to a Child List](#adding-an-item-to-a-child-list)
    * [Removing an Item from a Child List](#removing-an-item-from-a-child-list)
    * [Editing an Item on a Child List](#editing-an-item-on-a-child-list)
* [List Model Requirements](#list-model-requirements)
* [List Item Model Requirements](#list-item-model-requirements)
* [Aggregatable](#aggregatable)
  * [Associations](#associations)
  * [Scopes](#scopes)
  * [Validations](#validations)
  * [Hooks](#hooks)
  * [Methods](#methods)
  * [What's Automatic and What's Not](#whats-automatic-and-whats-not)

## Overview

Skyrim Inventory Management makes use of a concept called "aggregate lists". A model that represents a list of other models (e.g., `ShoppingList`, which is a list of `ShoppingListItem` models) can include the `Aggregatable` module to incorporate aggregate list behaviour. Currently, the only such class is `ShoppingList`, so that will be used as the example here, but there are other models in the pipeline that will incorporate this behaviour as well.

An aggregate list is a list that tracks and aggregates data from other lists (the child lists). When an item is added, removed, or modified on a child list, the corresponding item is added, removed, or modified on the aggregate list as well.

Above where you include `Aggregatable` in the model code, you will need to define a class method called `self.list_item_class_name` that is the class name, as a string, of the class the list items for this type of list belong to:

```ruby
class ShoppingList < ApplicationRecord
  def self.list_item_class_name
    'ShoppingListItem'
  end

  include Aggregatable
end
```

## Glossary

* **Aggregate List:** A list that tracks and aggregates data from a collection of regular lists of the same class. An aggregate list is differentiated from a regular list by its `aggregate` attribute, which is set to `true`. A user can have only one aggregate list for each list class.
* **Regular List:** Any list that is not an aggregate list.
* **Child List:** A regular list belonging to a particular aggregate list.
* **Should/Must:** Used in this document to describe things you will need to implement for models that include aggregate list behaviour.
* **Is/Does/Will:** Used in this document to describe behaviour provided out of the box by the `Aggregatable` concern.

## Database and ORM Requirements

The database schema for all models that include the `Aggregatable` concern must meet certain requirements:

| Column Name         | Type    | Constraints | Default |
| ------------------- | ------- | ----------- | ------- |
| `aggregate`         | boolean | NOT NULL    | false   |
| `aggregate_list_id` | integer |             |         |
| `user_id`           | integer | NOT NULL    |         |
| `title`             | string  | NOT NULL    |         |

The title for all aggregate lists is "All Items". The titles for other lists may be validated or set to a default value by the individual model if desired. Other than the title, these values should not be changed after initial creation.

You do not need to define any relations in your parent class, and defining a relation to list items may interfere with `Aggregatable`'s functionality.

The database schema for all child models (i.e., the list items for a given list type) must also meet certain requirements:

| Column Name   | Type    | Constraints   | Default |
| ------------- | ------- | ------------- | ------- |
| `list_id`     | integer | NOT NULL      |         |
| `description` | string  | NOT NULL      |         |
| `quantity`    | integer | NOT NULL, > 0 | 1       |
| `notes`       | string  |               |         |

**The list item's description should be unique per list and not editable.** List items are uniquely identified on the aggregate list by their descriptions. There should be a validation in place to make sure that descriptions cannot be changed. You will want to make sure to define your child model's relation to the parent:
```ruby
# /app/models/shopping_list_item.rb

class ShoppingListItem < ApplicationRecord
  belongs_to :list, class_name: 'ShoppingList', foreign_key: :list_id
end
```

Note that list items will be destroyed with their parent list.

## Aggregate List Behaviour

Aggregate list behaviour is complex and involves both list items and the lists themselves.

### Creation and Destruction of Aggregate Lists

Best practice for aggregate lists is to never create or update an aggregate list manually. The `Aggregatable` concern ensures that aggregate lists are created and destroyed automatically.

When a user creates their first regular list, an aggregate list will be automatically created for them and set as that list's aggregate list. Subsequent lists of the same class belonging to the same user should be created with that as the aggregate list:
```ruby
user.aggregate_shopping_list.child_lists.create!(title: 'My Title')
```

When a user destroys a regular list, and it is their last regular list of that class, the aggregate list will also be destroyed.

### Updating Aggregate Lists

The `Aggregatable` module does not automatically update an aggregate list when an item is added, removed, or modified on a child list, however, it does provide methods that you can use to do this updating. Updating is a core feature of aggregate lists but fully implementing it in the models proved too magical and was leading to a lot of complexity in the code.

#### Adding an Item to a Child List

When an item is added to a regular list, the corresponding aggregate list should also be updated. This can be done using the `#add_item_from_child_list` method, which handles all logic around adding items. This method will raise an `Aggregatable::AggregateListError` if it is called on a regular list.
```ruby
aggregate_list.add_item_from_child_list(item)
```

There are two possible cases: there is an item already on the aggregate list with the same description as the item being added, or there is not.

##### When There Is No Exising Item

If there is no item with the same description on the aggregate list already, one should be created on the aggregate list with the same attributes.

##### When There Is an Existing Item

If there is an item with the same description on the aggregate list already, that item will be updated as follows:

1. The `quantity` of the item on the aggregate list will be increased by the quantity of the item being added.
2. The `notes` of the item on the aggregate list will be concatenated with the new item's notes, separated with ` -- `

#### Removing an Item from a Child List

When an item is removed from a regular list, the corresponding aggregate list should also be updated. this can be done using the `#remove_item_from_child_list` method, which handles all logic around removing items. This method will raise an `Aggregatable::AggregateListError` if it is called on a regular list.
```ruby
aggregate_list.remove_item_from_child_list(item)
```

There are two possible cases:

1. The item on the aggregate list has the same quantity as the item being removed (meaning there is no other item with the same `description` on any of the aggregate list's children).
2. The item on the aggregate list has a quantity greater than that of the item being removed (meaning there's another item with the same `description` on another one of the aggregate list's children).

If the item passed in is not on the aggregate list, or if its quantity is greater than the quantity on the aggregate list, an `Aggregatable::AggregateListError` will be raised.

##### When the Quantity Is Equal

When the quantity of an item on the aggregate list is equal to the quantity of the list item being removed, the item is removed from the aggregate list.

##### When the Quantity Is Greater

When the quantity of an item on the aggregate list is greater than the quantity of the list item being removed, the quantity and notes are updated on the aggregate list item.

The quantity of the aggregate list item is reduced by the amount of the quantity of the item being removed. The notes are also updated to remove the notes associated with the item being removed. For example, if the aggregate list item's notes are `"notes 1 -- notes 2"` and the item being removed has notes `"notes 1"`, then the notes should be changed to `" -- notes 2"`. These straggling values can be cleaned up in the [list item model](#list-item-model-requirements).

#### Editing an Item on a Child List

There are two values that can be edited on a child list item: `notes` and `quantity`. One or both may be updated at a given time. The aggregate list values can be updated using the `#update_item_from_child_list` method. In order to call this method, you'll need to know four things:

* The `description` of the item being edited (to find on the aggregate list - remember that description should not be editable)
* The change in quantity, if any (should be negative if the quantity was reduced, positive if it was increased, and zero if it did not change)
* The old `notes` value
* The new `notes` value

The method will raise an `Aggregatable::AggregateListError` if called on a regular list or if the item being edited does not appear on the aggregate list.

##### Updating the Quantity

Once the item is found on the aggregate list, its `quantity` will be _increased_ by the value of the `delta_quantity` argument passed in. It is important that this value be negative if the `quantity` is to be reduced.

##### Updating the Notes

Once the item is found on the aggregate list, its `notes` value will be updated if there is a difference between the old and new values passed in. If the old value is changed, it will be replaced in the aggregate list item notes. If the value is changed to a blank or `nil` value, then the old value will be removed from the aggregate list item notes.

## List Model Requirements

Before including the `Aggregatable` module in your class, you will need to define the `list_item_class_name` class method. The method definition will need to be above where you include the module since it is used in the module's `included` block.

## List Item Model Requirements

Each list item model should implement `combine_or_new` and `combine_or_create!` methods. These methods look for a model on the same list matching the description passed in as an attribute. If no item on the same list matches that description, a new one is instantiated (or created). If there is a matching item on the same list, the quantity passed in should be added to the existing item's quantities and the notes fields on the existing and new items should be updated to aggregate the notes for both items.

List items also need a way to clean up automatically edited `notes` values. This should be done in a `before_save` hook and should account for the following cases:

* Leading `" -- "` (should be removed)
* Trailing `" -- "` (should be removed)
* Multiple consecutive `" -- "` in the middle of the list (should be turned into just one separator)
* A single `"--"` (should be removed)

For example:

* `" -- notes 2"` should be changed to `"notes 2"`
* `"notes 1 -- "` should be changed to  `"notes 1"`
* `"notes 1 --  -- -- notes 3"` should be changeed to `"notes 1 -- notes 3"`
* `"--"` should be changed to `nil`

Finally, list items need an `::index_order` scope to indicate how they should be returned with the list they're on (for the `ShoppingListItem` model, this order is descending `:updated_at` order).

In the future, these behaviours will probably also be extracted to an abstract class or another concern. For now, you can see a reference implementation [here](/app/models/shopping_list_item.rb).

## Aggregatable

The `Aggregatable` module provides aggregate list functionality to a list model. 

### Associations

* Association to `:user` (`belongs_to :user`)
* Association to `:aggregate_list` (`belongs_to :aggregate_list, foreign_key: :aggregate_list_id`)
* Association to `:child_lists` (`has_many :child_lists`)

Note that the `:aggregate_list` and `:child_lists` associated both belong to the same class as the aggregate list.

### Scopes

* `::aggregate_first` (returns lists with the aggregate list first)
* `::includes_items` (eager loads list items with the list)

### Validations

The `Aggregatable` concern validates that no list that is not an aggregate list can be named "All Items". List names are case-insensitive so this applies to any casing. Titles may contain "all items" (with any casing) as long as they don't consist entirely of that phrase.

The concern also includes a validation verifying that the user has only one aggregate list.

Finally, there are validations ensuring that the aggregate list is present for any regular list and that the list set as aggregate list is, in fact, an aggregate list.

### Hooks

The `Aggregatable` concern introduces several hooks to manage aggregate list behaviour.

#### before_validation

Before a regular list is created, if the user does not have an existing aggregate list, the aggregate list is created and set as the aggregate list for the regular list being created. This hook only runs for regular lists and nothing happens if the aggregate list already exists or the list is being updated as opposed to created.

#### before_save

The `#abort_if_aggregate_changed` hook ensures that the `aggregate` status of a list cannot be changed once the list has been created.

The `#remove_aggregate_list_id` hook ensures that aggregate lists do not belong to aggregate lists.

The `#set_title_to_all_items` hook sets the title to "All Items" if the list is an aggregate list.

#### before_destroy

The `#abort_if_aggregate` hook prevents aggregate lists that have extant children from being destroyed.


#### after_destroy

The `#destroy_aggregate_list` hook ensures that aggregate lists are destroyed when their last child is.

### Methods

#### `#add_item_from_child_list(item)`

Should be called on an aggregate list any time an item is added to one of its child lists. Handles logic for creating or combining list items on the aggregate list. Raises an `Aggregatable::AggregateListError` if called on a regular list. Returns the created or updated list item.

#### `#remove_item_from_child_list(item)`

Should be called on an aggregate list any time an item is removed/destroyed from one of its child lists. Handles logic for removing or updating list items on the aggregate list. Raises an `Aggregatable::AggregateListError` if called on a regular list. Returns the updated item from the aggregate list if its quantity is higher than that of the item removed and  otherwise `nil`.

#### `update_item_from_child_list(description, delta_quantity, old_notes, new_notes)`

Should be called on an aggregate list any time an item is updated on a child list. Raises an `Aggregatable::AggregateListError` if called on a regular list. Handles logic for updating items that already exist on a child list. Returns the updated list item from the aggregate list.

Arguments:

* `description`: The `description` of the item that has been changed (descriptions are not editable).
* `delta_quantity`: The difference between the new and old quantity on the updated item. Should be negative if the new quantity is lower and positive if it is higher.
* `old_notes`: The previous `notes` value of the item that has been changed
* `new_notes`: Thee updated `notes` value of the item that has been changed

#### `aggregate_list`

Returns the aggregate list to which the shopping list belongs. Is `nil` for aggregate lists.

#### `child_lists`

If called on an aggregate list, returns all its the associated lists. Is empty for regular lists.

### What's Automatic and What's Not

`Aggregatable` provides associations, validations, hooks, and scopes on the parent model out of the box. It doesn't provide an automatic mechanism to keep aggregate list _items_ up-to-date with their child lists' models. You will need to use the `#add_item_from_child_list`, `#remove_item_from_child_list`, and `#update_item_from_child_list` methods to do that any time you add, remove, or edit a list item on one of the child lists.