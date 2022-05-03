# Canonical Models

SIM knows certain things about Skyrim that it may or may not immediately reveal to users. Canonical models are models representing things in Skyrim the user may not know yet. Currently there are 8 canonical models:

* [`AlchemicalProperty`](/app/models/alchemical_property.rb): actual properties of ingredients or potions that exist in the game
* [`CanonicalArmor`](/app/models/canonical_armor.rb): actual armor pieces available in the game
* [`CanonicalClothingItem`](/app/models/canonical_clothing_item.rb): actual clothing items available in the game; includes mages' robes as well as plain clothes
* [`CanonicalJewelryItem`](/app/models/canonical_jewelry_item.rb): actual jewelry items available in-game, including both generic and unique pieces
* [`CanonicalMaterial`](/app/models/canonical_material.rb): actual building and smithing materials present in the game
* [`CanonicalProperty`](/app/models/canonical_property.rb): actual properties (homes) the player character can own in the game
* [`Enchantment`](/app/models/enchantment.rb): actual enchantments that exist in the game
* [`Spell`](/app/models/spell.rb): actual spells that exist in the game

These models are not user-created and are to be stored in the database with actual data from the game. The data from which the database is populated live in JSON files in the `/lib/tasks/canonical_models` directory. These JSON files contain attributes for each model that should exist in the database (whether in development or production).

Note that the models listed above do not include join tables for the `has_many, :through` relationships amongst the models listed. These include:

* [`CanonicalArmorsEnchantment`](/app/models/canonical_armors_enchantment.rb): Associates canonical armours to their enchantments, adding a metadata field called "strength" for the strength of the enchantment (in whatever its strength unit is)
* [`CanonicalClothingItemsEnchantment`](/app/models/canonical_clothing_items_enchantment.rb): Associates canonical clothing items to their enchantments, adding a metadata field called "strength" for the strength of the enchantment (in whatever its strength unit is)
* [`CanonicalJewelryItemsEnchantments`](/app/models/canonical_jewelry_items_enchantment.rb): Associates canonical jewellery items to their enchantments, adding a metadata field called "strength" for the strength of the enchantment (in whatever its strength unit is)
* [`CanonicalJewelryItemsCanonicalMaterial`](/app/models/canonical_jewelry_items_canonical_material.rb): Associates canonical jewellery items with the materials required to create them, adding a metadata field called "quantity" for the quantity of a given material required
* [`CanonicalArmorsSmithingMaterial`](/app/models/canonical_armors_smithing_material.rb): Associates canonical armours with the materials required to create them, adding a metadata field called "quantity" for the quantity of a given material required
* [`CanonicalArmorsTemperingMaterial`](/app/models/canonical_armors_tempering_material.rb): Associates canonical armours with the materials required to improve them, adding a metadata field called "quantity" for the quantity of a given material required

Note that the last two of these are associated to the same table - canonical materials - but have separate associations because the materials required to improve an item and those required to create it are distinct. If materials associations are blank, it means the item in question can't be forged or improved.

## Seeding Canonical Models

### Rake Tasks

The following idempotent Rake tasks can be used to populate the database with the canonical models from the JSON data or update existing models:

* `rails canonical_models:populate:all` (populates all canonical models from JSON data)
* `rails canonical_models:populate:alchemical_properties` (populates canonical alchemical properties from JSON data)
* `rails canonical_models:populate:canonical_properties` (populates canonical properties from JSON data)
* `rails canonical_models:populate:enchantments` (populates canonical enchantments from JSON data)
* `rails canonical_models:populate:spells` (populates canonical spells from JSON data)
* `rails canonical_models:populate:canonical_materials` (populates canonical materials from JSON data)
* `rails canonical_models:populate:canonical_armor` (populates canonical armours from JSON data)
* `rails canonical_models:populate:canonical_jewelry` (populates canonical jewellery from JSON data)
* `rails canonical_models:populate:canonical_clothing` (populates canonical clothing items from JSON data)

These tasks populate the models with the attributes in the JSON files. The tasks are idempotent. If a model already exists in the database with a given name, it will be updated with the attributes given in the JSON data. **The Rake tasks will not remove models that exist in the database but are not present in the JSON data.** (There is a [card](https://trello.com/c/YdoBROVq/161-modify-rake-tasks-for-populating-canonical-items-to-clean-up-items-not-in-json-files) in the backlog to make the Rake tasks remove database items that are not in the JSON data.)

In addition to seeding the models, the Rake task also creates canonical associations - for example, adding enchantments to items that are canonically enchanted with one or more of the standard enchantments or smithing materials to armours. Because of this, canonical materials and enchantments will need to be seeded before canonical armours or jewellery can be. Canonical clothing doesn't have materials and is therefore only dependent on enchantments.

### Running Rake Tasks in Production

To run the Rake tasks in production, use the `heroku run` CLI command from within this repo (you will need to log in to Heroku):
```
heroku login
heroku run bundle exec rails canonical_models:populate:all
```
