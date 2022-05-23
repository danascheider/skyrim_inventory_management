# Canonical Models and Data

Skyrim Inventory Management uses canonical models hidden from the user, primarily to handle complex validations of user-generated data. Canonical models represent actual items, enchantments, powers, alchemical properties, and spells that are present in Skyrim and discoverable by the user. The purpose of these models is twofold:

* **Validate user input:** In cases where users input data pertaining to specific objects (such as for inventory lists), validate that the objects input actually exist in the game
* **Identify properties of discovered objects:** When a user inputs an object, identify the corresponding in-game object to provide the application with insights into its attributes that the user may not know

These models are synced to the database using JSON data present in

The documentation in this directory covers the purpose of canonical models, the canonical models that exist in SIM, their associations, and specifics pertaining to particular models that require additional explanation.

## Table of Contents

* [Canonical Models](/docs/canonical_models/canonical-models.md): An overview of canonical models, which canonical models exist, and associations between them
* [Canonical Data](/docs/canonical_models/canonical-data.md): Working with the JSON data and exporting CSV files
* [Syncing Canonical Models](/docs/canonical_models/syncing-canonical-models.md): Using Rake tasks to sync canonical models in the database with authoritative JSON data
* Specific Models
  * [Canonical::Book](/docs/canonical_models/canonical-book.md): Additional details about special characteristics of the `Canonical::Book` model
  * [Canonical::IngredientsAlchemicalProperty](/docs/canonical_models//canonical-ingredients-alchemical-property.md): Additional details about special characteristics of the `Canonical::IngredientsAlchemicalProperty` model