# Shopping Lists

Shopping lists represent lists of items a user needs in a given game. Users can have different lists corresponding to different property locations within each game. Games with shopping lists also have an aggregate list that includes the combined list items and quantities from all the other lists for that game. Aggregate lists are created, updated, and destroyed automatically. They cannot be created, updated, or destroyed through the API (including to change attributes or to add, remove, or update list items).

Each list contains [shopping list items](/docs/api/resources/shopping-list-items.md), which are returned with each response that includes the list.

When making requests to update the title of a shopping list, there are some validations and automatic transformations to keep in mind:

* Titles must be unique per game - you cannot name two lists the same thing within the same game
* Only an aggregate list can be called "All Items"
* All aggregate lists are called "All Items" and there is no way to rename them something else
* Titles are saved with headline casing regardless of the case submitted in the request (for example, "lOrd of the rINgS" will be saved as "Lord of the Rings")
* If the request includes a blank title, then the title will be saved as "My List N", where N is the integer above the highest nonnegative integer used in an existing "My List" title (so if the game has "My List 1" and "My List 3", the next time the user tries to save a list for that game without a title it will be called "My List 4")
* Leading and trailing whitespace will be stripped from titles before they are saved, so " My List 2  " becomes "My List 2"
* Titles may only contain alphanumeric characters, spaces, hyphens, apostrophes, and commas - any other characters (that aren't leading or trailing whitespace, which will be stripped regardless) cause the API to return a 422 response

Like other resources in SIM, shopping lists are scoped to the authenticated user. There is no way to retrieve or manage shopping lists for any other user through the API.

## Endpoints

* [`GET /games/:game_id/shopping_lists`](#get-gamesgame_idshopping_lists)
* [`POST /games/:game_id/shopping_lists`](#post-gamesgame_idshopping_lists)
* [`PATCH|PUT /shopping_lists/:id`](#patchput-shopping_listsid)
* [`DELETE /shopping_lists/:id`](#delete-shopping_listsid)

## GET /games/:game_id/shopping_lists

Returns all shopping lists for the game indicated by the `:game_id` param, provided the game exists and is owned by the authenticated user. The aggregate shopping list will be returned first, followed by the game's other shopping lists in reverse chronological order by `updated_at` (i.e., the lists that were edited most recently will be on top).

### Example Request

```
GET /shopping_lists
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
        "description": "Unenchanted ebony sword",
        "quantity": 1,
        "notes": "Need an unenchanted sword to start Companions questline",
        "unit_weight": null,
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      },
      {
        "list_id": 43,
        "description": "Iron ingot",
        "quantity": 4,
        "notes": "3 locks -- 2 hinges",
        "unit_weight": 1.0,
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
        "description": "Unenchanted ebony sword",
        "quantity": 1,
        "notes": "Need an unenchanted sword to start Companions questline",
        "unit_weight": null,
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      },
      {
        "list_id": 46,
        "description": "Iron ingot",
        "quantity": 3,
        "notes": "3 locks",
        "unit_weight": 1.0,
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
        "notes": "2 hinges",
        "unit_weight": 1.0,
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

## POST /games/:game_id/shopping_lists

Creates a new shopping list for the specified game if it exists and belongs to the authenticated user. If the game does not already have an aggregate list, an aggregate list will also be created automatically. The response is an array that includes all shopping lists belonging to the specified game. Each shopping list also includes an array with any shopping list items on that list. The JSON schema for the shopping list items is described in the [docs for shopping list items](/docs/api/resources/shopping-list-items.md). The shopping lists are returned with the aggregate list first and subsequent lists in order of most recently updated. (Adding, removing, or updating a list item on a list counts as updating the list.)

The request does not have to include a body. If it does, the body should include a `"shopping_list"` object with an optional `"title"` key, the only attribute that can be set on a shopping list via this or any endpoint. If you don't include a title, your list will be titled "My List N", where _N_ is an integer equal to one plus the highest numbered default list title you have. For example, if you have lists titled "My List 1", "My List 3", and "My List 4" and you don't specify a title for your new list, your new list will be titled "My List 5".

There are a few validations and automatic changes made to titles:

* Titles must be unique per game - you cannot name two of one game's lists the same thing
* Only an aggregate list can be called "All Items"
* All aggregate lists are called "All Items" and there is no way to rename them something else
* Titles are saved with headline casing regardless of the case submitted in the request (for example, "lOrd of the rINgS" will be saved as "Lord of the Rings")
* If the request includes a blank title, then the title will be saved as "My List N", where N is the integer above the highest integer used in an existing "My List" title (so if the user has "My List 1" and "My List 3", the next time the client creates a list without a title, it will be called "My List 4")

### Example Requests

Request specifying a title:
```
POST games/1455/shopping_lists
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "shopping_list": {
    "title": "Custom Title"
  }
}
```

Request not specifying a title (list will be given a default title as defined above):
```
POST /games/8928/shopping_lists
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{ "shopping_list": {} }
```

Request with no request body (the list will be given a default title as defined above):
```
POST /games/8928/shopping_lists
Authorization: Bearer xxxxxxxxxx
```

### Success Responses

#### Statuses

* 201 Created

#### Example Body

```json
[
  {
    "id": 4,
    "user_id": 6,
    "aggregate": true,
    "aggregate_list_id": null,
    "title": "All Items",
    "created_at": "Tue, 15 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Tue, 15 Jun 2021 11:59:16.891338000 UTC +00:00",
    "list_items": [
      {
        "id": 33,
        "list_id": 4,
        "description": "Ebony sword",
        "quantity": 1,
        "notes": "To enchant with Soul Trap",
        "unit_weight": 14.0,
        "created_at": "Tue, 15 Jun 2021 12:34:32.713458000 UTC +00:00",
        "updated_at": "Tue, 15 Jun 2021 12:34:32.713458000 UTC +00:00"
      }
    ]
  },
  {
    "id": 12,
    "user_id": 6,
    "aggregate": false,
    "aggregate_list_id": 4,
    "title": "Custom Titled List",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "list_items": []
  },
  {
    "id": 5,
    "user_id": 6,
    "aggregate": false,
    "aggregate_list_id": 4,
    "title": "My List 1",
    "created_at": "Tue, 15 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Tue, 15 Jun 2021 11:59:16.891338000 UTC +00:00",
    "list_items": [
      {
        "id": 32,
        "list_id": 5,
        "description": "Ebony sword",
        "quantity": 1,
        "notes": "To enchant with Soul Trap",
        "unit_weight": 14.0,
        "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
        "updated_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00"
      }
    ]
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
  "errors": ["Cannot manually create an aggregate shopping list"]
}
```

A 500 error response, which is always a result of an unforeseen problem, includes the error message:
```json
{
  "errors": ["Something went horribly wrong"]
}
```

## PATCH|PUT /shopping_lists/:id

If the specified shopping list exists, belongs to the authenticated user, and is not an aggregate list, updates the title and returns the shopping list. Title is the only shopping list attribute that can be modified using this endpoint. This endpoint also supports the `PUT` method. There is no  difference in application behaviour whether `PATCH` or `PUT` is used.

### Example Requests

Requests should include a `"shopping_list"` object with a `"title"` key. The `"title"` may be `null`; in this case, a default title will be assigned as described [above](#post-gamesgame_idshopping_lists). If the `"shopping_list"` object is empty or nonexistent, or if no request body is given, the list will not be updated but will be returned as-is. `"title"` is the only attribute that may be set on shopping lists via the SIM API.

#### PATCH Requests

Normal usage:

```
PATCH /shopping_lists/3
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "shopping_list": {
    "title": "New List Title"
  }
}
```

Null title (will result in a default title being assigned):

```
PATCH /shopping_lists/3
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "shopping_list": {
    "title": null
  }
}
```

Empty `"shopping_list"` object (shopping list will be returned as-is):

```
PATCH /shopping_lists/3
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "shopping_list": {}
}
```

#### PUT Requests

Normal usage:

```
PUT /shopping_lists/3
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "shopping_list": {
    "title": "New List Title"
  }
}
```

Null title (will result in a default title being assigned):

```
PUT /shopping_lists/3
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "shopping_list": {
    "title": null
  }
}
```

Empty `"shopping_list"` object (shopping list will be returned as-is):

```
PUT /shopping_lists/3
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{
  "shopping_list": {}
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
      "unit_weight": 14.0,
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
  "errors": ["Cannot manually update an aggregate shopping list"]
}
```

A 500 error response, which is always a result of an unforeseen problem, includes the error message:

```json
{
  "errors": ["Something went horribly wrong"]
}
```

## DELETE /shopping_lists/:id

Destroys the given shopping list, and any shopping list items on it, if it exists and belongs to the authenticated user. If the list to be destroyed is the user's only regular (non-aggregate) shopping list, the aggregate list will also be destroyed. The response body will include any remaining shopping lists belonging to the game to which the requested list belongs.

### Example Request

```
DELETE /shopping_lists/428
Authorization: Bearer xxxxxxxxxxxx
```

### Success Response

#### Statuses

* 200 OK

#### Example Bodies

The response body will be an array of any remaining shopping lists belonging to the same game as the destroyed list(s).

Body including an aggregate list and an additional list that was not destroyed:

```json
[
  {
    "id": 834,
    "user_id": 16,
    "aggregate": true,
    "aggregate_list_id": null,
    "title": "All Items",
    "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "list_items": [
      {
        "id": 32,
        "list_id": 834,
        "description": "Ebony sword",
        "quantity": 1,
        "notes": "To enchant with Soul Trap",
        "unit_weight": 14.0,
        "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ]
  },
  {
    "id": 835,
    "user_id": 16,
    "aggregate": false,
    "aggregate_list_id": 834,
    "title": "Vlindrel Hall",
    "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "list_items": [
      {
        "id": 31,
        "list_id": 835,
        "description": "Ebony sword",
        "quantity": 1,
        "notes": "To enchant with Soul Trap",
        "unit_weight": 14.0,
        "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ]
  }
]
```

Empty body indicating aggregate list was also destroyed:

```json
[]
```

### Error Responses

If the specified list does not exist or does not belong to the authenticated user, a 404 response will be returned. If the specified list is an aggregate list, a 405 response will be returned.

#### Statuses

* 404 Not Found
* 405 Method Not Allowed
* 500 Internal Server Error

#### Example Bodies

For a 404 response, no response body will be returned.

For a 405 response:

```json
{
  "errors": ["Cannot manually delete an aggregate shopping list"]
}
```

A 500 error response, which is always a result of an unforeseen problem, includes the error message:

```json
{
  "errors": ["Something went horribly wrong"]
}
```
