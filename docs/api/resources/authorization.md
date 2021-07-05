# Authorization

Skyrim Inventory Management uses [Sign In With Google](https://developers.google.com/identity/sign-in/web/sign-in) to authenticate users. Session data is stored on the [front end](https://github.com/danascheider/skyrim_inventory_management_frontend) and the API verifies the OAuth token on each request. On initial sign-in, the client should make a request to [GET /auth/verify_token](#get-auth-verify_token) with the bearer token from Google included in the authorization header.

## Contents

* [`GET /auth/verify_token`](#get-authverifytoken)

## GET /auth/verify_token

This endpoint verifies user tokens on initial sign-in and ensures that the user has an up-to-date account or profile on the server. The account is created or updated using the profile data returned from Google, not with client-provided data. Users are uniquely identified by the email that Google returns on token verification. If a user signs in with a different Google account, or if Google returns a different email address for some reason, a separate account will be created with the new email and will not be linked to the user's original account. Users must keep track of which account they've used to sign in.

### Example Request

```
GET /auth/verify_token
Authorization: Bearer xxxxxxxxxxxxx
```

### Success Responses

#### Status

204 No Content

### Error Responses

#### Status

401 Unauthorized

#### Example Bodies

OAuth token validation failure:
```json
{
  "error": "Google OAuth token validation failed"
}
```

Failed certificate validation:
```json
{
  "error": "Invalid OAuth certificate"
}
```

