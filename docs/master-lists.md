# Master Lists

## Contents

* [Overview](#overview)
* [Glossary](#glossary)
* [Database Requirements](#database-requirements)
* [Master List Behaviour](#master-list-behaviour)
  * [Creation and Destruction of Master Lists](#creation-and-destruction-of-master-lists)
  * [Updating Master Lists](#updating-master-lists)
    * [Adding an Item to a Child List](#adding-an-item-to-a-child-list)
    * [Removing an Item from a Child List](#removing-an-item-from-a-child-list)
    * [Editing an Item on a Child List](#editing-an-item-on-a-child-list)
* [List Model Requirements](#list-model-requirements)
* [List Item Model Requirements](#list-item-model-requirements)
* [MasterListable](#masterlistable)
  * [Associations](#associations)
  * [Scopes](#scopes)
  * [Validations](#validations)
  * [Hooks](#hooks)
  * [Methods](#methods)

## Overview

Skyrim Inventory Management makes use of a concept called "master lists". A model that represents a list of other models (e.g., `ShoppingList`, which is a list of `ShoppingListItem` models) can include the `MasterListable` module to incorporate master list behaviour. Currently, the only such class is `ShoppingList`, so that will be used as the example here, but there are other models in the pipeline that will incorporate this behaviour as well.

A master list is a list that tracks and aggregates data from other lists (the child lists). When an item is added, removed, or modified on a child list, the corresponding item is added, removed, or modified on the master list as well.

Above where you include `MasterListable` in the model code, you will need to define a class method called `self.list_item_class_name` that is the class name, as a string, of the class the list items for this type of list belong to:

```ruby
class ShoppingList < ApplicationRecord
  def self.list_item_class_name
    'ShoppingListItem'
  end

  include MasterListable
end
```

## Glossary

* **Master List:** A list that tracks and aggregates data from a collection of regular lists of the same class. A master list is differentiated from a regular list by its `master` attribute, which is set to `true`. A user can have only one master list for each list class.
* **Regular List:** Any list that is not a master list.
* **Child List:** A regular list belonging to a particular master list.
* **Should/Must:** Used in this document to describe things you will need to implement for models that include master list behaviour.
* **Is/Does/Will:** Used in this document to describe behaviour provided out of the box by the `MasterListable` module.

## Database Requirements

The database schema for all models that include the `MasterListable` module must meet certain requirements:

| Column Name | Type | Constraints | Notes |
| ----------- | ---- | ----------- | ----- |
| `master`      | boolean | default: false | Indicates whether the list is a master list |
| `master_list_id` | integer | | Reference to the master list (if this list is not a master list) |
| `user_id` | integer | NOT NULL | Reference to the user whose lists these are |
| `title` | string | NOT NULL | The title of the list (will be set to "Master" for master lists) |

The database schema for all child models (i.e., list items for a given list type) must also meet certain requirements:

| Column Name | Type | Constraints | Notes |
| ----------- | ---- | ----------- | ----- |
| `list_id`      | integer | NOT NULL | The list to which the item belongs |
| `description` | string | | The item's title or description |
| `quantity` | integer | NOT NULL, default: 1 | The quantity of the item |
| `notes` | string | | Any notes about the item |

**The list item's description should be unique per list and not editable.** List items are uniquely identified on the master list by their descriptions. There should be a validation in place to make sure that descriptions cannot be changed.

## Master List Behaviour

Master list behaviour is complex and involves both list items and the lists themselves.

### Creation and Destruction of Master Lists

Best practice for master lists is to never create or update a master list manually. The `MasterListable` concern ensures that master lists are created and destroyed automatically.

When a user creates their first regular list, a master list will be automatically created for them and set as that list's master list. Subsequent lists of the same class belonging to the same user should be created with that as the master list:
```ruby
user.master_shopping_list.child_lists.create!(title: 'My Title')
```

When a user destroys a regular list, and it is their last regular list of that class, the master list will also be destroyed.

### Updating Master Lists

The `MasterListable` module does not automatically update a master list when an item is added, removed, or modified on a child list, however, it does provide methods that you can use to do this updating. Updating is a core feature of master lists but fully implementing it in the models proved too magical and was leading to a lot of complexity in the code.

#### Adding an Item to a Child List

When an item is added to a regular list, the corresponding master list should also be updated. This can be done using the `#add_item_from_child_list` method, which handles all logic around adding items. This method will raise a `MasterListError` if it is called on a regular list.
```ruby
master_list.add_item_from_child_list(item)
```

There are two possible cases: there is an item already on the master list with the same description as the item being added, or there is not.

##### When There Is No Exising Item

If there is no item with the same description on the master list already, one should be created on the master list with the same attributes.

##### When There Is an Existing Item

If there is an item with the same description on the master list already, that item will be updated as follows:

1. The `quantity` of the item on the master list will be increased by the quantity of the item being added.
2. The `notes` of the item on the master list will be concatenated with the new item's notes, separated with ` -- `

#### Removing an Item from a Child List

When an item is removed from a regular list, the corresponding master list should also be updated. this can be done using the `#remove_item_from_child_list` method, which handles all logic around removing items. This method will raise a `MasterListError` if it is called on a regular list.
```ruby
master_list.remove_item_from_child_list(item)
```

There are two possible cases:

1. The item on the master list has the same quantity as the item being removed (meaning there is no other item with the same `description` on any of the master list's children).
2. The item on the master list has a quantity greater than that of the item being removed (meaning there's another item with the same `description` on another one of the master list's children).

If the item passed in is not on the master list, or if its quantity is greater than the quantity on the master list, a `MasterListError` will be raised.

##### When the Quantity Is Equal

When the quantity of an item on the master list is equal to the quantity of the list item being removed, the item is removed from the master list.

##### When the Quantity Is Greater

When the quantity of an item on the master list is greater than the quantity of the list item being removed, the quantity and notes are updated on the master list item.

The quantity of the master list item is reduced by the amount of the quantity of the item being removed. The notes are also updated to remove the notes associated with the item being removed. For example, if the master list item's notes are `"notes 1 -- notes 2"` and the item being removed has notes `"notes 1"`, then the notes should be changed to `" -- notes 2"`. These straggling values can be cleaned up in the [list item model](#list-item-model-requirements).

#### Editing an Item on a Child List

There are two values that can be edited on a child list item: `notes` and `quantity`. One or both may be updated at a given time. The master list values can be updated using the `#update_item_from_child_list` method. In order to call this method, you'll need to know four things:

* The `description` of the item being edited (to find on the master list - remember that description should not be editable)
* The change in quantity, if any (should be negative if the quantity was reduced, positive if it was increased, and zero if it did not change)
* The old `notes` value
* The new `notes` value

The method will raise a `MasterListError` if called on a regular list or if the item being edited does not appear on the master list.

##### Updating the Quantity

Once the item is found on the master list, its `quantity` will be _increased_ by the value of the `delta_quantity` argument passed in. It is important that this value be negative if the `quantity` is to be reduced.

##### Updating the Notes

Once the item is found on the master list, its `notes` value will be updated if there is a difference between the old and new values passed in. If the old value is changed, it will be replaced in the master list item notes. If the value is changed to a blank or `nil` value, then the old value will be removed from the master list item notes.

## List Model Requirements

Before including the `MasterListable` module in your class, you will need to define the `list_item_class_name` class method. The method definition will need to be above where you include the module since it is used in the module's `included` block.

## List Item Model Requirements

Each list item model should implement `combine_or_new` and `combine_or_create!` methods. These methods look for a model on the same list matching the description passed in as an attribute. If no item on the same list matches that description, a new one is instantiated (or created). If there is a matching item on the same list, the quantity passed in should be added to the existing item's quantities and the notes fields on the existing and new items should be updated to aggregate the notes for both items.

List items also need a way to clean up automatically edited `notes` values. This should be done in a `before_save` hook and should account for the following cases:

* Leading `" -- "` (should be removed)
* Trailing `" -- "` (should be removed)
* Multiple `" -- "` next to each other in the middle of the list (should be turned into just one separator)

For example:

* `" -- notes 2"` should be changed to `"notes 2"`
* `"notes 1 -- "` should be changed to  `"notes 1"`
* `"notes 1 --  -- notes 3"` should be changeed to `"notes 1 -- notes 3"`

Finally, list items need an `::index_order` scope to indicate how they should be returned with the list they're on (for the `ShoppingListItem` model, this order is descending `:updated_at` order).

In the future, these behaviours will probably also be extracted to an abstract class or another concern. For now, you can see a reference implementation [here](/app/models/shopping_list_item.rb).

## MasterListable

The `MasterListable` module provides master list functionality to a list model. It adds the following out of the box.

### Associations

* Association to `:user` (`belongs_to :user`)
* Association to `:master_list` (`belongs_to :master_list, foreign_key: :master_list_id`)
* Association to `:child_lists` (`has_many :child_lists`)

Note that the `:master_list` and `:child_lists` associated both belong to the same class as the master list.

### Scopes

* `::master_first` (returns lists with the master list first)
* `::includes_items` (includes list items with the list)

### Validations

The `MasterListable` concern validates that no list that is not a master list can be named "Master". List names are case-insensitive so this applies to any casing. Titles may contain "master" (with any casing) as long as they don't consist entirely of that word.

The concern also includes a validation verifying that the user has only one master list.

Finally, there are validations ensuring that the master list is present for any regular list and that the list set as master list is, in fact, a master list.

### Hooks

The `MasterListable` concern introduces several hooks to manage master list behaviour.

#### before_validation

Before a regular list is created, if the user does not have an existing master list, the master list is created and set as the master list for the regular list being created. This hook only runs for regular lists and nothing happens if the master list already exists or the list is being updated as opposed to created.

#### before_save

The `#abort_if_master_changed` hook ensures that the `master` status of a list cannot be changed once the list has been created.

The `#remove_master_list_id` hook ensures that master lists do not belong to master lists.

The `#set_title_to_master` hook sets the title to "Master" if the list is a master list.

#### before_destroy

The `#abort_if_master` hook prevents master lists that have extant children from being destroyed.


#### after_destroy

The `#destroy_master_list` hook ensures that master lists are destroyed when their last child is.

### Methods

#### `#add_item_from_child_list(item)`

Should be called on a master list any time an item is added to one of its child lists. Handles logic for creating or combining list items on the master list. Raises a `MasterListError` if called on a regular list.

#### `#remove_item_from_child_list(item)`

Should be called on a master list any time an item is removed/destroyed from one of its child lists. Handles logic for removing or updating list items on the master list. Raises a `MasterListError` if called on a regular list.

#### `update_item_from_child_list(description, delta_quantity, old_notes, new_notes)`

Should be called on a master list any time an item is updated on a child list. Raises a `MasterListError` if called on a regular list. Handles logic for updating items that already exist on a child list.

Arguments:

* `description`: The `description` of the item that has been changed (descriptions are not editable).
* `delta_quantity`: The difference between the new and old quantity on the updated item. Should be negative if the new quantity is lower and positive if it is higher.
* `old_notes`: The previous `notes` value of the item that has been changed
* `new_notes`: Thee updated `notes` value of the item that has been changed
