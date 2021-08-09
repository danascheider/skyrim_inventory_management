# Inventory Lists

Inventory lists represent lists of items a user has, whether carried or stored at one of the user's properties. Users can have different lists corresponding to different locations or carried inventory within each game. Games with inventory lists also have an aggregate list that includes the combined list items and quantities from all the other lists for that game. Aggregate lists are created, updated, and destroyed automatically. They cannot be created, updated, or destroyed through the API (including to change attributes or to add, remove, or update list items).

Each list contains [inventory list items](/docs/api/resources/inventory-list-items.md), which are returned with the list in any response that includes it.

When making requests to update the title of an inventory list, there are some validations and automatic transformations to keep in mind.

* Titles must be unique per game - you cannot name two lists the same thing within the same game
* Only an aggregate list can be called "All Items"
* All aggregate lists are called "All Items" and there is no way to rename them something else
* Titles are saved with headline casing regardless of the case submitted in the request (for example, "lOrd of the rINgS" will be saved as "Lord of the Rings")
* If the request includes a blank title, then the title will be saved as "My List N", where N is the integer above the highest nonnegative integer used in an existing "My List" title (so if the game has "My List -4" and "My List 3", the next time the user tries to save a list for that game without a title it will be called "My List 4")
* Leading and trailing whitespace will be stripped from titles before they are saved, so " My List 2  " becomes "My List 2"
* Titles may only contain alphanumeric characters, spaces, hyphens, apostrophes, and commas - any other characters (other than leading or trailing whitespace, which will be stripped regardless) cause the API to return a 422 response

Like other resources in SIM, inventory lists are scoped to the authenticated user. There is no way to retrieve or manage inventory lists for any other user through the API.

## Endpoints

* [`GET /games/:game_id/inventory_lists`](#get-gamesgame_idinventory_lists)
* [`POST /games/:game_id/inventory_lists`](#post-gamesgame_idinventory_lists)

## GET /games/:game_id/inventory_lists

Returns all inventory lists for the game indicated by the `:game_id` param, provided the game exists and is owned by the authenticated user. The aggregate inventory list will be returned first, followed by the game's other inventory lists in reverse chronological order by `updated_at` (i.e., the lists that were edited most recently will be first).

### Example Request

```
GET /inventory_lists
Authorization: Bearer xxxxxxxxxxxxx
```

### Success Responses

#### Statuses

* 200 OK

#### Example Bodies

For a game with no lists:
```json
[]
```
For a game with multiple lists:
```json
[
  {
    "id": 43,
    "game_id": 8234,
    "aggregate": true,
    "title": "All Items",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "list_items": [
      {
        "list_id": 43,
        "description": "Ebony sword",
        "quantity": 1,
        "notes": "Enchanted with Absorb Health",
        "unit_weight": 14,
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      },
      {
        "list_id": 43,
        "description": "Iron ingot",
        "quantity": 4,
        "notes": null,
        "unit_weight": 1,
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ]
  },
  {
    "id": 46,
    "game_id": 8234,
    "aggregate": false,
    "aggregate_list_id": 43,
    "title": "Lakeview Manor",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "list_items": [
      {
        "list_id": 46,
        "description": "Ebony sword",
        "quantity": 1,
        "notes": "Enchanted with Absorb Health",
        "unit_weight": 14,
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      },
      {
        "list_id": 46,
        "description": "Iron ingot",
        "quantity": 3,
        "notes": null,
        "unit_weight": 1,
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ]
  },
  {
    "id": 52,
    "game_id": 8234,
    "aggregate": false,
    "aggregate_list_id": 43,
    "title": "Severin Manor",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "list_items": [
      {
        "list_id": 52,
        "description": "Iron ingot",
        "quantity": 1,
        "notes": null,
        "unit_weight": 1,
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ]
  }
]
```

### Error Responses

In general, no errors are expected to be returned from this endpoint. However, unanticipated problems can always come up.

#### Statuses

* 404 Not Found
* 500 Internal Server Error

#### Example Bodies

A 404 error is the result of the game not being found or not belonging to the authenticated user. It does not include a response body.

A 500 error response, which is always a result of an unforeseen problem, includes the error message:
```json
{
  "errors": ["Something went horribly wrong"]
}
```

## POST /games/:game_id/inventory_lists

Creates a new inventory list for the specified game if it exists and belongs to the authenticated user. If the game does not already have an aggregate list, an aggregate list will also be created automatically. The response is an array that includes the newly created inventory list(s).

The request does not have to include a body. If it does, the body should include an `"inventory_list"` object with an optional `"title"` key, the only attribute that can be set on an inventory list via request data. If you don't include a title, your list will be titled "My List N", where _N_ is an integer equal to the highest numbered default list title you have for that game. For example, if one of your games has lists titled "My List 1", "My List 3", and "My List 4" and you don't specify a title for the new list you're requesting for the game, your new list will be titled "My List 5".

There are a few validations and automatic changes made to titles:

* Titles must be unique per game - you cannot name two of one game's lists the same thing
* Only an aggregate list can be called "All Items"
* All aggregate lists are called "All Items" and there is no way to rename them something else
* Titles are saved with headline casing regardless of the case submitted in the request (for example, "lOrd of the rINgS" will be saved as "Lord of the Rings")
* If the request includes a blank title, then the title will be saved as "My List N", where N is the integer above the highest integer used in an existing "My List" title (so if the user has "My List 1" and "My List 3", the next time the client creates a list without a title, it will be called "My List 4")

### Example Requests

Request specifying a title:
```
POST games/1455/inventory_lists
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "inventory_list": {
    "title": "Custom Title"
  }
}
```

Request not specifying a title (list will be given a default title as defined above):
```
POST /games/8928/inventory_lists
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{ "inventory_list": {} }
```

Request with no request body (the list will be given a default title as defined above):
```
POST /games/8928/inventory_lists
Authorization: Bearer xxxxxxxxxx
```

### Success Responses

#### Statuses

* 201 Created

#### Example Bodies

When there hasn't been an aggregate list created:
```json
{
  "id": 4,
  "user_id": 6,
  "aggregate": false,
  "aggregate_list_id": 3,
  "title": "My List 1",
  "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "list_items": []
}
```

When the aggregate list has also been created:
```json
[
  {
    "id": 4,
    "user_id": 6,
    "aggregate": true,
    "title": "All Items",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  },
  {
    "id": 5,
    "user_id": 6,
    "aggregate": false,
    "aggregate_list_id": 4,
    "title": "My List 1",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
  }
]
```

### Error Responses

#### Statuses

* 404 Not Found
* 422 Unprocessable Entity
* 500 Internal Server Error

#### Example Bodies

If the game with the given `game_id` is not found or does not belong to the authenticated user, a 404 response will be returned. This response will have no body.

If duplicate title is given:
```json
{
  "errors": ["Title must be unique per game"]
}
```

If request attempts to create an aggregate list:
```json
{
  "errors": ["Cannot manually create an aggregate inventory list"]
}
```

A 500 error response, which is always a result of an unforeseen problem, includes the error message:
```json
{
  "errors": ["Something went horribly wrong"]
}
```

## PATCH|PUT /inventory_lists/:id

If the specified inventory list exists, belongs to the authenticated user, and is not an aggregate list, updates the title and returns the inventory list. Title is the only inventory list attribute that can be modified using this endpoint. This endpoint also supports the `PUT` method.

### Example Requests

Requests must include a `"inventory_list"` object with a `"title"` key.

Using a `PATCH` request:
```
PATCH /inventory_lists/3
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "inventory_list": {
    "title": "New List Title"
  }
}
```

Using a `PUT` request:
```
PUT /inventory_lists/3
Authorization: Bearer xxxxxxxxxxx
Content-Type: application/json
{
  "inventory_list": {
    "title": "New List Title"
  }
}
```

### Success Response

#### Statuses

* 200 OK

#### Example Body

```json
{
  "id": 834,
  "user_id": 16,
  "aggregate": false,
  "aggregate_list_id": 833,
  "title": "New List Title",
  "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
  "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "list_items": [
    {
      "id": 32,
      "list_id": 834,
      "description": "Ebony sword",
      "quantity": 1,
      "notes": "To enchant with Soul Trap",
      "unit_weight": 14,
      "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
      "updated_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00"
    }
  ]
}
```

### Error Responses

#### Statuses

* 404 Not Found
* 405 Method Not Allowed
* 422 Unprocessable Entity
* 500 Internal Server Error

#### Example Bodies

For a 404 response, no response body is returned.

For a 422 response due to title uniqueness constraint:
```json
{
  "errors": ["Title must be unique per game"]
}
```

For a 405 response due to attempting to update an aggregate list or convert a regular list to an aggregate list:
```json
{
  "errors": ["Cannot manually update an aggregate inventory list"]
}
```

A 500 error response, which is always a result of an unforeseen problem, includes the error message:
```json
{
  "errors": ["Something went horribly wrong"]
}
```
