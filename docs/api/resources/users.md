# Users

Skyrim Inventory Management offers only one route for retrieving user profile data. There are no admin users or endpoints to retrieve data for multiple or unauthenticated users. Additionally, there is no way to modify user profile data through the API. User data is populated through the Sign In With Google verification API. Users wishing to update their profiles in SIM should update the Google profile they use to log in.

## Endpoints

* [`GET /users/current`](#get-userscurrent)

## GET /users/current

Returns the user authenticated with the bearer token included in the `Authorization` header. Error responses are the same as for the `GET /auth/verify_token` endpoint.

### Example Request

```
GET /users/current
Authorization: Bearer xxxxxxxxx
```

### Successful Responses

#### Status

200 OK

#### Example Body

```json
{
  "id": 241,
  "uid": "janedoe@gmail.com",
  "email": "janedoe@gmail.com",
  "image_url": "https://example.googleusercontent.com",
  "name": "Jane Doe"
}
```
