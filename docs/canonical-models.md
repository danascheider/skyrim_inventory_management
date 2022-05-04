# Canonical Models

SIM knows certain things about Skyrim that it may or may not immediately reveal to users. Canonical models are models representing things in Skyrim the user may not know yet. Currently there are the following canonical models:

* [`AlchemicalProperty`](/app/models/alchemical_property.rb): actual properties of ingredients or potions that exist in the game
* [`CanonicalArmor`](/app/models/canonical_armor.rb): actual armor pieces available in the game
* [`CanonicalClothingItem`](/app/models/canonical_clothing_item.rb): actual clothing items available in the game; includes mages' robes as well as plain clothes
* [`CanonicalIngredient`](/app/models/canonical_ingredient.rb): actual ingredients available in the game; has many-to-many association to `AlchemicalProperty`, which it can have no more than 4 of without causing a validation error
* [`CanonicalJewelryItem`](/app/models/canonical_jewelry_item.rb): actual jewelry items available in-game, including both generic and unique pieces
* [`CanonicalMaterial`](/app/models/canonical_material.rb): actual building and smithing materials present in the game
* [`CanonicalProperty`](/app/models/canonical_property.rb): actual properties (homes) the player character can own in the game
* [`Enchantment`](/app/models/enchantment.rb): actual enchantments that exist in the game
* [`Spell`](/app/models/spell.rb): actual spells that exist in the game

These models are not user-created and are to be stored in the database with actual data from the game. The data from which the database is syncd live in JSON files in the `/lib/tasks/canonical_models` directory. These JSON files contain attributes for each model that should exist in the database (whether in development or production).

Note that the models listed above do not include join tables for the `has_many, :through` relationships amongst the models listed, although these are similarly syncd in the SIM database with data from the game. These include:

* [`AlchemicalIngredientsCanonicalIngredient](/app/models/alchemical_properties_canonical_ingredient.rb): Associates canonical ingredients with the `AlchemicalProperty` model; no more than 4 can be created for each ingredient before a validation error is raised
* [`CanonicalArmorsEnchantment`](/app/models/canonical_armors_enchantment.rb): Associates canonical armours to their enchantments, adding a metadata field called "strength" for the strength of the enchantment (in whatever its strength unit is)
* [`CanonicalClothingItemsEnchantment`](/app/models/canonical_clothing_items_enchantment.rb): Associates canonical clothing items to their enchantments, adding a metadata field called "strength" for the strength of the enchantment (in whatever its strength unit is)
* [`CanonicalJewelryItemsEnchantments`](/app/models/canonical_jewelry_items_enchantment.rb): Associates canonical jewellery items to their enchantments, adding a metadata field called "strength" for the strength of the enchantment (in whatever its strength unit is)
* [`CanonicalJewelryItemsCanonicalMaterial`](/app/models/canonical_jewelry_items_canonical_material.rb): Associates canonical jewellery items with the materials required to create them, adding a metadata field called "quantity" for the quantity of a given material required
* [`CanonicalArmorsSmithingMaterial`](/app/models/canonical_armors_smithing_material.rb): Associates canonical armours with the materials required to create them, adding a metadata field called "quantity" for the quantity of a given material required
* [`CanonicalArmorsTemperingMaterial`](/app/models/canonical_armors_tempering_material.rb): Associates canonical armours with the materials required to improve them, adding a metadata field called "quantity" for the quantity of a given material required

Note that the last two of these are associated to the same table - canonical materials - but have separate associations because the materials required to improve an item and those required to create it are distinct. If materials associations are blank, it means the item in question can't be forged or improved.

## Seeding Canonical Models

### Rake Tasks

The following idempotent Rake tasks can be used to sync the database with the canonical models with the JSON data:

* `rails canonical_models:sync:all` (syncs all canonical models with JSON data)
* `rails canonical_models:sync:alchemical_properties` (syncs canonical alchemical properties with JSON data)
* `rails canonical_models:sync:canonical_properties` (syncs canonical properties with JSON data)
* `rails canonical_models:sync:enchantments` (syncs canonical enchantments with JSON data)
* `rails canonical_models:sync:spells` (syncs canonical spells with JSON data)
* `rails canonical_models:sync:canonical_materials` (syncs canonical materials with JSON data)
* `rails canonical_models:sync:canonical_armor` (syncs canonical armours with JSON data)
* `rails canonical_models:sync:canonical_jewelry` (syncs canonical jewellery with JSON data)
* `rails canonical_models:sync:canonical_clothing` (syncs canonical clothing items with JSON data)
* `rails canonical_models:sync:canonical_ingredients` (sync canonical ingredients with JSON data)

These tasks sync the models with the attributes in the JSON files. The tasks are idempotent. If a model already exists in the database with a given name, it will be updated with the attributes given in the JSON data. This is also true of associations: if an association is found in the database then the corresponding model (or join model) will be updated with data from the JSON files. **The Rake tasks will also remove models that exist in the database but are not present in the JSON data.** This behaviour can be disabled by setting the `preserve_existing_records` argument on the Rake tasks to `true` (or any value other than `false`):

```
bundle exec rails 'canonical_models:sync:all[true]'
```

This argument can also be set on the individual tasks:

```
bundle exec rails 'canonical_models:sync:canonical_properties[true]'
```

In addition to seeding the models, the Rake task also creates canonical associations - for example, adding enchantments to items that are canonically enchanted with one or more of the standard enchantments or smithing materials to armours. Because of this, tasks to sync apparel items list the one that syncs enchantments as prerequisites. Tasks to sync jewellery and armour items also require `canonical_models:sync:canonical_materials` as a prerequisite. (Clothing items don't have materials and are therefore only dependent on enchantments.) If the `preserve_existing_records` argument is set to `false` (which is its default value) when the Rake task is invoked, any associations with `dependent: :destroy` set will be destroyed along with any corresponding records not included in the JSON data. Additionally, associations that are not present in the JSON data will be destroyed as well.

### Running Rake Tasks in Production

To run the Rake tasks in production, use the `heroku run` CLI command from within this repo (you will need to log in to Heroku):
```
heroku login
heroku run bundle exec rails canonical_models:sync:all
```
