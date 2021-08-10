# API Documentation

Skyrim Inventory Management API offers a range of endpoints allowing users to store, retrieve, and remove data about their inventory and tasks.

## Endpoints

All endpoints accept and return JSON bodies only. Unless otherwise specified, all endpoints are authenticated using an `Authorization` header including the bearer token from Google OAuth. The API is stateless and all requests must be authenticated individually. Requests including a request body should include a `Content-Type` header set to `"application/json"`.

Authorization is handled in a `before_action` on the `ApplicationController`. Unless otherwise indicated, error statuses for all resources can include any of the error statuses the [`GET /auth/verify`](/docs/api/resources/authorization.md) returns.

## Authorization

See docs:

* [Authorization](/docs/api/authorization.md)

## Resources

* [Games](/docs/api/resources/games.md)
* [Inventory List Items](/docs/api/resources/inventory-list-items.md)
* [Inventory Lists](/docs/api/resources/inventory-lists.md)
* [Shopping List Items](/docs/api/resources/shopping-list-items.md)
* [Shopping Lists](/docs/api/resources/shopping-lists.md)
* [Users](/docs/api/resources/users.md)

### Object Modelling Hierarchy

In SIM, users can have any number of games, which can each have any number of shopping lists, which can each have any number of shopping list items. An authenticated user can create, access, update, and destroy resources belonging to them. There are currently no admin routes or any way to access resources not belonging to the currently authenticated user (except through direct database access).
