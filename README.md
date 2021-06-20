# Skyrim Inventory Management API

[Skyrim Inventory Management](https://sim.danascheider.com) is a fully featured, split-stack Rails/React app enabling users to manage inventory and tasks across multiple properties in Skyrim. The back end API found in this repo is hosted on [Heroku](https://heroku.com) at https://sim-api.danascheider.com. 

## Disclaimer

This application is my hobby project intended for my personal use and all other users should use at their own risk. There are no admin users who can fix anything you break about your own account or data, so if you fuck something up, consider it fucked. I do have certain access to data on account of being able to access the logs and database directly through Heroku, but don't count on my help for anything because (1) I can't guarantee I can do anything about your specific problem and (2) I don't have the bandwidth or executive function to consistently and promptly act in a support capacity on this app for other users. I'll help if I can because I'm not an asshole but I'm not making any promises. In particular, note that I do not keep backup data, nor does this app do [soft deletes](https://www.dailysmarty.com/posts/how-to-soft-delete-in-rails). Any data you delete is gone forever.

## Authentication

Skyrim Inventory Management uses [Sign In With Google](https://developers.google.com/identity/sign-in/web/sign-in) to handle authentication. Indeed, I undertook development of this app with a primary goal of learning to implement OAuth/Sign In With Google on a split-stack app. All API routes are authenticated and resources are automatically scoped to the authenticated user. Sessions are maintained on the [front end](https://github.com/danascheider/skyrim_inventory_management_frontend) and the Google OAuth token is verified by the back end on each request using the wonderfully user-friendly [google-id-token](https://github.com/google/google-id-token) gem. The API itself is stateless--it keeps no user session data and each request has to be individually authenticated.

Authentication is handled using the Google-issued OAuth token as a [bearer token](https://oauth.net/2/bearer-tokens/#:~:text=Bearer%20Tokens%20are%20the%20predominant,such%20as%20JSON%20Web%20Tokens.). The token is included in the `Authorization` header on every API request. The token is verified in a `before_action` defined on the `ApplicationController`, and a 401 response is sent from that `before_action` if the token isn't present, can't be verified, or has expired. If the front-end receives a 401 response from the server, it invalidates the token and the user has to log in again.

Users are uniquely identified by the email address associated with the Google account they use to sign in. The API does not intelligently link accounts if a user has logged in under multiple Google accounts at different times - each account they log in with will have its own SIM user and no access to resources associated with other accounts.

### Authenticating Resources

All resources are scoped to the currently authenticated user. Requesting a resource that doesn't belong to the authenticated user will result in a 404, not a 401. So, if User 1 owns the `ShoppingList` with ID 24, requesting `/shopping_lists/24` with User 2's token will simply result in the resource not being found, and not in a 401 response.

## Resources

### Users

All resources are scoped to the user authenticated during a given request. Profile information for users is automatically updated with data returned from Google on token verification. The profile stores only the user's name, email, and profile image URL from Google. Of these, email is king: a user's email cannot be changed and if, for some reason, Google returns a different email, a new user account will be created with no association to the original one. The user's `uid` is also set to their email.

There are no admin users or other special user accounts and thus no way to view data for users other than the one authenticated in the current request.

#### Schema

```
id: integer, primary key, unique, not null
uid: string, unique, not null
email: string, unique, not null, generally equal to `uid`
image_url: string or null
name: string or null
```

### Shopping Lists

Shopping lists provide a flexible way to track which items you need. The only property of a shopping list is its `"user_id"`. Every shopping list has many [shopping list items](/#shopping-list-items), which are included in `GET` requests that return that list.

#### Schema

```
id: integer, primary key, unique, not null
user_id: integer, foreign key, not null
master: boolean, only one master allowed per user
title: string, unique per user, default value of 'Master' if master and 'My List n' otherwise
```

#### Master Shopping Lists

Users can have multiple shopping lists. In the future, each list will correspond to a location or property where the items are needed. For example, a user might need 10 iron ingots at Heljarchen Hall and 4 iron ingots at Lakeview Manor. In this case, the user might have a shopping list for Heljarchen Hall including 10 iron ingots and another list for Lakeview Manor including 4 iron ingots.

It is also useful to know the total quantity of an item that a user needs. For this reason, every user also has a master list that is created when the user creates their first shopping list. This list is automatically updated to include all shopping list items on any of the user's other lists. If there are items with the same (case-insensitive) `description` on multiple lists, those items will be combined into a single item on the master list with the `quantity` being the sum of the quantities specified on each other list where the item occurs. Every time an item is added, updated, or removed from another list, the master list is automatically updated to reflect changes to the items or quantities.

The title of all master shopping lists is "Master". Master lists can be retrieved through the API but cannot be created, updated, or destroyed, including adding or removing items, as these functions are all handled automatically.

### Shopping List Items

Shopping list items have three properties: a text `description`, an integer `quantity`, and text `notes`. To provide maximum flexibility, there are no restrictions on the `description` field - it can be any description of an item needed and doesn't have to be in terms that are specific or meaningful to the game. Examples could be:

* "Unenchanted ebony sword"
* "Item with Fortify Carry Weight enchantment"
* "Necklace with Resist Frost enchantment"
* "Helmet or circlet"
* "Iron, steel, or imperial sword"
* "Ingredient with Fortify Sneak property"

#### Schema

```
id: integer, primary key, unique, not null
shopping_list_id: integer, foreign key, not null
description: string, unique on each shopping list, not null
quantity: integer, not null
notes: string
```
