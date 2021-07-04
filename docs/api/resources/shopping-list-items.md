# Shopping List Items

Shopping list items represent the items on a user's [shopping lists](/docs/api/resources/shopping-lists.md). Shopping list items on regular lists can be created, updated, and destroyed through the API. Shopping list items on the user's master shopping list are managed automatically as the items on their other lists change. Each shopping list item belongs to a particular list and will be destroyed if the list is destroyed.

There are no read routes (`GET /shopping_list_items`, `GET /shopping_list/:id/shopping_list_items`, or `GET /shopping_list_items/:id`) for shopping list items since all shopping list items are returned with the lists they are on when requests are made to the list routes. There are, however, routes to create, update, and destroy shopping list items.

All requests to shopping list item endpoints must be [authenticated](/docs/api/resources/authorization.md).

## Automatically Managed Master Lists

Skyrim Inventory Management makes use of automatically managed master lists to help users track an aggregate of what items they need for different properties. The master list is created automatically when the client creates a user's first regular shopping list, and is destroyed automatically when the client deletes the user's last regular shopping list. When items are added, updated, or destroyed from any of a user's regular lists, master list items are updated as described in this section.

### Creating a New List Item

If the client requests a new list item be created on a user's regular list, one of the following things will happen:

* If there is not an item with the same (case-insensitive) `description` on the master list, then an item with the same `description`, `quantity`, and `notes` will be created on the master list.
* If there is an item with the same (case-insensitive) `description` on the master list, then that item will be updated:
  * The description will not be changed
  * The quantity will be increased by the quantity of the new list item
  * The notes for the two items will be concatenated and separated by ` -- `

### Updating a List Item

When a client updates a list item on a user's regular list, one or more of the following things will happen:

* If the quantity is increased, the quantity of the item on the master list will be increased by the same amount
* If the quantity is decreased, the quantity of the item on the master list will be decreased by the same amount
* If the notes are changed, SIM will ensure that the new notes are reflected in the master list item

### Destroying a List Item

When a client destroys a list item on a user's regular shopping list, one of the following things will happen:

* If the quantity of the item on the user's master shopping list is higher than the quantity of the item deleted (i.e., if there is another matching item on a different list), the master list item's quantity will be decreased by the amount of the quantity of the deleted item.
* If the quantity on the user's master shopping list is equal to the quantity of the item deleted (i.e., if there is not another matching item on a different list), the item on the master shopping list will be deleted as well.

## Endpoints

The following endpoints are available to manage shopping list items:

* [`POST /shopping_lists/:id/shopping_list_items`](#post-shoppinglistsidshoppinglistitems)

## POST /shopping_lists/:id/shopping_list_items

If the shopping list with the given ID exists, belongs to the authenticated user, is not a master shopping list, and does not have an existing shopping list item with the same (case-insensitive) description, creates a shopping list item on the given list. If all these conditions are met but the list does have an existing shopping list item with a matching description, it updates the quantity and notes on the existing item.

In both cases, the user's master list is also updated to reflect the new quantity and notes.

Requests must specify a `description` and an integer `quantity` greater than 0. The optional `notes` field is an arbitrary string where users can keep any reminders of what the item will be used for or other useful notes.

A successful response will return a JSON array of two items. The first item is the item from the user's master list that has been added or updated as a result of the request. The second item is the item created or updated from the client's request.

### Example Request

```
POST /shopping_lists/72/shopping_list_items
Authorization: Bearer xxxxxxxxxxx
Content-Type: application/json
{
  "description": "Ebony sword",
  "quantity": 7,
  "notes": "To enchant with 'Absorb Health'"
}
```

### Success Responses

#### Statuses

* 200 OK

#### Example Body

```json
[
  {
    "id": 87,
    "shopping_list_id": 238,
    "description": "Ebony sword",
    "quantity": 9,
    "notes": "To sell -- To enchant with 'Absorb Health'",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Fri, 02 Jul 2021 12:04:27.161932000 UTC +00:00"
  },
  {
    "id": 126,
    "shopping_list_id": 237,
    "description": "Ebony sword",
    "quantity": 7,
    "notes": "To enchant with 'Absorb Health'",
    "created_at": "Fri, 02 Jul 2021 12:04:27.161932000 UTC +00:00",
    "updated_at": "Fri, 02 Jul 2021 12:04:27.161932000 UTC +00:00"
  }
]
```

### Error Responses

Several error responses are posssible.

#### Statuses

* 404 Not Found
* 405 Method Not Allowed
* 422 Unprocessable Entity

#### Example Bodies

No body will be returned with a 404 error, which is returned if the specified shopping list doesn't exist or doesn't belong to the authenticated user.

A 405 error, which is returned if the specified shopping list is a master shopping list, comes with the following body:
```json
{
  "error": "Cannot manage master shopping list items directly."
}
```

A 422 error, returned as a result of a validation error, includes whichever errors prevented the list item from being created:
```json
{
  "errors": {
    "quantity": ["must be a number", "must be greater than zero"],
    "description": ["is required"]
  }
}
```