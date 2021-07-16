# Games

Each user in Skyrim Inventory Management can have many games. The game is the base resource that owns other resources a user may create, such as shopping lists and shopping list items. All game routes are scoped to the currently authenticated user. There are no admin routes or any way to access, create, remove, or modify data from a user that is not currently authenticated.

## Endpoints

There is currently one endpoint available:

* [`POST /games`](#post-games)

## POST /games

Creates a game for the authenticated user with the given attributes. Requests may or may not include JSON request bodies. If a body is included, it should have a `"game"` key whose value is an object. That object can contain the keys `"name"` and `"description"`, both of which are optional. If a `"name"` is not specified, the game will be created with a default name. Default names take the form "My Game N", where _N_ is an integer one higher than the highest existing number in a default name. So if a user has games named "My Game 1" and "My Game 3", their next default-titled game will be "My Game 4". If a user chooses to specify a name, the name must consist of alphanumeric characters, spaces, commas, hyphens, and/or apostrophes. Other values will result in a 422 response. Additionally, game names must be unique per user.

### Example Requests

Request with no request body (will result in a default name being given to the new game, and an empty description):
```
POST /games
Authorization: Bearer xxxxxxxx
```

Request with a request body specifying a name and description:
```
POST /games
Authorization: Bearer xxxxxxxx
Content-Type: application/json
{
  "game": {
    "name": "My Non Default Game Name"
  }
}
```

### Success Responses

#### Statuses

* 201 Created

#### Example Bodies

```json
{
  "id": 83226,
  "user_id": 20082,
  "name": "My Game 1",
  "description": "This could also be null",
  "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
}
```

### Error Responses

#### Statuses

* 422 Unprocessable Entity
* 500 Internal Server Error

#### Example Bodies

A 422 response results from a validation error when the attributes provided in the request don't fit the requirements of the API. It includes an array of the errors that prevented the game from being created:
```json
{
  "errors": ["Name is already taken"]
}
```

A 500 error will be returned only when an unanticipated error is raised. The response body will include the error message.
```json
{
  "errors": ["Something went horribly wrong"]
}
```
