# User Authentication

SIM resources are authenticated using Sign in with Google. The front end receives access tokens from Google when the user logs in and sends them to the back end in the `"Authorization"` header as bearer tokens. This is handled in the `authenticate_user!` action, defined in the `ApplicationController` class. This action makes use of the [`ApplicationController::AuthorizationService`](/app/controller_services/application_controller/authorization_service.rb) to determine whether a user's login is valid.

## The Authorization Service

The authorization service validates the token sent in the `"Authorization"` header with Google by making a request to Google's API endpoint with the key stored in `Rails.application.credentials[:google][:firebase_web_api_key]`. The body of a successful response looks like this:

```json
{
  "kind": "identitytoolkit#GetAccountInfoResponse",
  "users": [
    {
      "localId": "somestring",
      "email": "someuser@gmail.com",
      "displayName": "Jane Doe",
      "photoUrl": "https://lh3.googleusercontent.com/a/userprofilephotourl",
      "emailVerified": true,
      "providerUserInfo": [
        {
          "providerId": "google.com",
          "displayName": "Jane Doe",
          "photoUrl": "https://lh3.googleusercontent.com/a/userprofilephotourl",
          "federatedId": "102936205639625087729",
          "email": "someuser@gmail.com",
          "rawId": "102936205639625087729"
        }
      ],
      "validSince": "1677533238",
      "lastLoginAt": "1678307939591",
      "createdAt": "1677533238988",
      "lastRefreshAt": "2023-03-08T23:05:56.946Z"
    }
  ]
}
```

If the response indicates a success status and the body's `"users"` array includes exactly one user, that user will be set as the current user via the `User::create_or_update_for_google` method. This method uniquely identifies the user by the `uid`, corresponding to the `localId` in the user object sent from Google. If no user with that `uid` exists in the database, a new one is created using the data from Google's response. All resources requested by the front end in this request will be scoped to this user; if a requested resource exists but does not belong to this user, a 404 response will be returned to the front end.

Under any other circumstances, a 401 response is returned to the front end. This includes when:

* Google returns a non-200-range response
* The `"users"` array in the response body is empty or contains multiple users
* Any error is raised