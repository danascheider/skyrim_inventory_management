# Shopping Lists

Shopping lists represent lists of items a user needs in the game. Users can have different lists corresponding to different property locations. Users with shopping lists also have a master list that includes the combined list items and quantities from all their other lists. Master lists are created, updated, and destroyed automatically. They cannot be created, updated, or destroyed through the API (including to change attributes or to add, remove, or update list items).

Each list contains list items, which are returned with each response that includes the list.

Like other resources in SIM, shopping lists are scoped to the authenticated user. There is no way to retrieve shopping lists for any other user through the API.

## Endpoints

* [`GET /shopping_lists`](#get-shoppinglists)
* [`GET /shopping_lists/:id`](#get-shoppinglistsid)
* [`POST /shopping_lists`](#post-shoppinglists)
* [`PUT|PATCH /shopping_lists/:id`](#patch-shoppinglistsid)
* [`DELETE /shopping_lists/:id`](#delete-shoppinglistsid)

## GET /shopping_lists

Returns all shopping lists owned by the authenticated user. The master shopping list will be returned first.

### Example Request

```
GET /shopping_lists
Authorization: Bearer xxxxxxxxxxxxx
```

### Successful Responses

#### Status

200 OK

#### Example Bodies

For a user with no lists:
```json
[]
```
For a user with multiple lists:
```json
[
  {
    "id": 43,
    "user_id": 8234,
    "master": true,
    "title": "Master",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "shopping_list_items": [
      {
        "shopping_list_id": 43,
        "description": "Unenchanted ebony sword",
        "quantity": 1,
        "notes": "Need an unenchanted sword to start Companions questline",
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      },
      {
        "shopping_list_id": 43,
        "description": "Iron ingot",
        "quantity": 4,
        "notes": "3 locks -- 2 hinges",
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ]
  },
  {
    "id": 46,
    "user_id": 8234,
    "master": false,
    "title": "Lakeview Manor",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "shopping_list_items": [
      {
        "shopping_list_id": 46,
        "description": "Unenchanted ebony sword",
        "quantity": 1,
        "notes": "Need an unenchanted sword to start Companions questline",
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      },
      {
        "shopping_list_id": 46,
        "description": "Iron ingot",
        "quantity": 3,
        "notes": "3 locks",
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ]
  },
  {
    "id": 52,
    "user_id": 8234,
    "master": false,
    "title": "Severin Manor",
    "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "shopping_list_items": [
      {
        "shopping_list_id": 52,
        "description": "Iron ingot",
        "quantity": 1,
        "notes": "2 hinges",
        "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ]
  }
]
```

## GET /shopping_lists/:id

Returns the shopping list with the given ID, if it exists and belongs to the authenticated user. The response includes any list items on the given shopping list. If the shopping list exists but does not belong to the authenticated user, a 404 error response will be returned.

### Example Request

```
GET /shopping_lists/24
Authorization: Bearer xxxxxxxxxxxx
```

### Successful Responses

#### Status

200 OK

#### Example Body

```json
{
  "id": 4,
  "user_id": 6,
  "master": false,
  "title": "My List 1",
  "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "shopping_list_items": [
    {
      "id": 1,
      "shopping_list_id": 4,
      "description": "Ebony sword",
      "quantity": 2,
      "notes": "One to enchant with Absorb Health, one to enchant with Soul Trap",
      "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
      "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
    }
  ]
}
```

### Error Responses

#### Status

404 Not Found

## POST /shopping_lists

Creates a new shopping list for the authenticated user. If the user does not already have a master list, a master list will also be created automatically. The response includes the newly created shopping list.

The request does not have to include a body. If it does, the body should include a `"shopping_list"` object with an optional `"title"` key, the only attribute that can be set on the shopping list via request data. If you don't include a title, your list will be titled "My List n", where _n_ is an integer equal to the highest numbered default list title you have. For example, if you have lists titled "My List 1", "My List 3", and "My List 4", your new list will be titled "My List 5".

Each list title must be unique for the authenticated user. So, multiple users can have lists called "My List 1", but if you have such a list and attempt to create a new list with the same title, the API will return an error.

### Example Requests

Request specifying a title:
```
POST /shopping_lists
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
POST /shopping_lists
Authorization: Bearer xxxxxxxxxx
Content-Type: application/json
{}
```

### Success Responses

#### Status

201 Created

#### Example Body

```json
{
  "id": 4,
  "user_id": 6,
  "master": false,
  "title": "My List 1",
  "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "shopping_list_items": []
}
```

### Error Responses

#### Status

422 Unprocessable Entity

#### Example Bodies

If duplicate title is given:
```json
{
  "errors": {
    "title": ["has already been taken"]
  }
}
```

If request attempts to create a master list:
```json
{
  "errors": {
    "master": ["cannot create or update a master shopping list through the API"]
  }
}
```

## PATCH /shopping_lists/:id

If the specified shopping list exists, belongs to the authenticated user, and is not a master list, updates the title and returns the shopping list. Title is the only shopping list attribute that can be modified using this endpoint. This endpoint also supports the `PUT` method.

### Example Requests

Requests must include a `"shopping_list"` object with a `"title"` key.

Using a `PATCH` request:
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

Using a `PUT` request:
```
PUT /shopping_lists/3
Authorization: Bearer xxxxxxxxxxx
Content-Type: application/json
{
  "shopping_list": {
    "title": "New List Title"
  }
}
```

### Success Response

#### Status

200 OK

#### Example Body

```json
{
  "id": 834,
  "user_id": 16,
  "master": false,
  "title": "New List Title",
  "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
  "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "shopping_list_items": [
    {
      "id": 32,
      "shopping_list_id": 834,
      "description": "Ebony sword",
      "quantity": 1,
      "notes": "To enchant with Soul Trap",
      "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
      "updated_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00"
    }
  ]
}
```

### Error Responses

#### Statuses

422 Unprocessable Entity
404 Not Found

#### Example Bodies

Unprocessable entity due to title uniqueness constraint:
```json
{
  "errors": {
    "title": ["has already been taken"]
  }
}
```

Unprocessable entity due to attempting to update a master list or convert a regular list to a master list:
```json
{
  "errors": {
    "master": ["cannot create or update a master shopping list through the API"]
  }
}
```

No response body is returned for a 404 response.

## DELETE /shopping_lists/:id

Destroys the given shopping list if it exists and belongs to the authenticated user. If the list to be destroyed is the user's only regular (non-master) shopping list, the master list will also be destroyed.

### Example Request

```
DELETE /shopping_lists/428
Authorization: Bearer xxxxxxxxxxxx
```

### Success Response

#### Statuses

204 No Content
200 OK

#### Example Body

If the resource deleted was the user's last regular list, the master list will also be destroyed and no content will be returned in the response. If the user had at least one other regular list (as well as a master list), then the master list will be returned with its values updated to reflect removal of the items on the list that was deleted.

```json
{
  "master_list": {
    "id": 834,
    "user_id": 16,
    "master": true,
    "title": "Master",
    "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
    "shopping_list_items": [
      {
        "id": 32,
        "shopping_list_id": 834,
        "description": "Ebony sword",
        "quantity": 1,
        "notes": "To enchant with Soul Trap",
        "created_at": "Tue, 15 Jun 2021 12:34:32.713457000 UTC +00:00",
        "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
      }
    ] 
  }
}
```

### Error Responses

If the specified list does not exist or does not belong to the authenticated user, a 404 response will be returned. If the specified list is a master list, a 405 response will be returned. Error responses do not return data.

#### Statuses

404 Not Found
405 Method Not Allowed

#### Example Body

No response body will be returned with a 404 response.

For a 405 response:
```json
{
  "error": "cannot destroy a master shopping list through the API"
}
```
