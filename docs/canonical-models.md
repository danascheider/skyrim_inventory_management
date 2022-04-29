# Canonical Models

SIM knows certain things about Skyrim that it may or may not immediately reveal to users. Canonical models are models representing things in Skyrim the user may not know yet. Currently there are three canonical models:

* [`AlchemicalProperty`](/app/models/alchemical_property.rb): actual properties of ingredients or potions that exist in the game
* [`CanonicalArmor`](/app/models/canonical_armor.rb): actual armor pieces available in the game
* [`CanonicalClothingItem`](/app/models/canonical_clothing_item.rb): actual clothing items available in the game; includes mages' robes as well as plain clothes
* [`CanonicalMaterial`](/app/models/canonical_material.rb): actual building and smithing materials present in the game
* [`CanonicalProperty`](/app/models/canonical_property.rb): actual properties (homes) the player character can own in the game
* [`Enchantment`](/app/models/enchantment.rb): actual enchantments that exist in the game
* [`Spell`](/app/models/spell.rb): actual spells that exist in the game

These models are not user-created and are to be stored in the database with actual data from the game. The data from which the database is populated live in JSON files in the `/lib/tasks/canonical_models` directory. These JSON files contain attributes for each model that should exist in the database (whether in development or production).

## Seeding Canonical Models

### Rake Tasks

The following idempotent Rake tasks can be used to populate the database with the canonical models from the JSON data or update existing models:

* `rails canonical_models:populate:all` (populates all canonical models from JSON data)
* `rails canonical_models:populate:alchemical_properties` (populates canonical alchemical properties from JSON data)
* `rails canonical_models:populate:canonical_properties` (populates canonical properties from JSON data)
* `rails canonical_models:populate:enchantments` (populates canonical enchantments from JSON data)
* `rails canonical_models:populate:spells` (populates canonical spells from JSON data)

These tasks populate the models with the attributes in the JSON files. The tasks are idempotent. If a model already exists in the database with a given name, it will be updated with the attributes given in the JSON data.

### Running Rake Tasks in Production

To run the Rake tasks in production, use the `heroku run` CLI command from within this repo (you will need to log in to Heroku):
```
heroku login
heroku run bundle exec rails canonical_models:populate:all
```
