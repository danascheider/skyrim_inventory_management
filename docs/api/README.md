# API Documentation

Skyrim Inventory Management API offers a range of endpoints allowing users to store, retrieve, and remove data about their inventory and tasks.

## Endpoints

All endpoints accept and return JSON bodies only. Unless otherwise specified, all endpoints are authenticated using an `Authorization` header including the bearer token from Google OAuth. The API is stateless and all requests must be authenticated individually. Requests including a request body should include a `Content-Type` header set to `"application/json"`.

Authorization is handled in a `before_action` on the `ApplicationController`. Unless otherwise indicated, error statuses for all resources can include any of the error statuses the [`GET /auth/verify`](/docs/api/resources/authorization.md) returns.

## Resources

* [Authorization](/docs/api/resources/authorization.md)
* [Users](/docs/api/resources/users.md)
* [Shopping Lists](/docs/api/resources/shopping-lists.md)
