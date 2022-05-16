# Canonical Models

SIM knows certain things about Skyrim that it may or may not immediately reveal to users. However, it will prevent users from creating impossible objects for UX reasons. Which objects are impossible is a hard question to answer without canonical data: the actual set of objects that exist in Skyrim. The purpose of canonical models is to store the data used to validate user input. The following canonical models exist in the SIM database:

* [`Canonical::Armor`](/app/models/canonical/armor.rb): actual armor pieces available in the game
* [`Canonical::ClothingItem`](/app/models/canonical/clothing_item.rb): actual clothing items available in the game; includes mages' robes as well as plain clothes
* [`Canonical::Ingredient`](/app/models/canonical/ingredient.rb): actual ingredients available in the game; has many-to-many association to `AlchemicalProperty`, which it can have no more than 4 of without causing a validation error
* [`Canonical::JewelryItem`](/app/models/canonical/jewelry_item.rb): actual jewelry items available in-game, including both generic and unique pieces
* [`Canonical::Material`](/app/models/canonical/material.rb): actual building and smithing materials present in the game
* [`Canonical::Property`](/app/models/canonical/property.rb): actual properties (homes) the player character can own in the game
* [`Canonical::Staff`](/app/models/canonical/staff.rb)
* [`Canonical::Weapon`](/app/models/canonical/weapon.rb): actual weapons the player character can acquire in the game
* [`Canonical::Staff`](/app/models/canonical/staff.rb): actual staves the player character can acquire in the game

These models represent prototypes of objects users may find in-game and enter into their inventory.The data from which the database is synced live in JSON files in the `/lib/tasks/canonical_models` directory. These JSON files contain attributes for each model that should exist in the database (whether in development or production).

There are additional models that can also be considered canonical, but are not namespaced under the `Canonical` module. These models are named differently because their function is to be discovered in the game and associated to objects the user finds or creates, not to validate data the user has entered. These models are:

* [`AlchemicalProperty`](/app/models/alchemical_property.rb): actual properties of ingredients or potions that exist in the game
* [`Enchantment`](/app/models/enchantment.rb): actual enchantments that exist in the game
* [`Spell`](/app/models/spell.rb): actual spells that exist in the game
* [`Power`](/app/models/power.rb): actual powers and abilities that exist in the game

Note that the models listed above do not include join tables for the `has_many, :through` relationships amongst the models listed, although these are similarly synced in the SIM database with data from the game. These include:

* [`Canonical::EnchantablesEnchantment`](/app/models/canonical/enchantables_enchantment.rb): This polymorphic join table associates enchantments with any enchantable items, including armours, jewellery, clothing items, and weapons, adding a field called `strength` for the strength of the enchantment on that particular item
* [`Canonical::CraftablesCraftingMaterial`](/app/models/canonical/craftables_crafting_material.rb): This polymorphic join table associates canonical materials with any items that are able to be crafted using those materials, including armours, jewellery, and weapons, adding a field called `quantity` for the quantity of a given material needed to craft that particular item
* [`Canonical::PowerablesPower](/app/models/canonical/powerables_power.rb): This polymorphic join table associates powers with any objects enchanted with them, including weapons and staves, adding no additional fields to the join table
* [`Canonical::StavesSpell](/app/models/canonical/staves_spell.rb): This join table links enchanted staves to the spells they are enchanted with, adding a `strength` field in case the strength of the spell on the staff differs from the base strength of the spell
* [`Canonical::TemperablesTemperingMaterial`](/app/models/canonical/temperables_tempering_material.rb): This polymorphic join table associates canonical materials with any items that are able to be tempered using those materials, including armours and weapons, adding a field called `quantity` for the quantity of a given material needed to temper that particular item
* [`Canonical::IngredientsAlchemicalProperty](/app/models/canonical/ingredients_alchemical_property.rb): Associates canonical ingredients with the `AlchemicalProperty` model; no more than 4 can be created for each ingredient before a validation error is raised; additional docs available [here](/docs/models/canonical-ingredients-alchemical-property.md)

Note that weapons and armour items have multiple associations to the same table - canonical materials - but the associations are separate since materials required to improve an item and those required to create it are distinct. If materials associations are blank, it means the item in question can't be crafted or improved.

## Syncing Canonical Models

For more information about the `Canonical::Sync` module, which powers the Rake tasks that sync the canonical models, see the [docs for that module](/docs/syncing-canonical-models.md).

### Rake Tasks

The following idempotent Rake tasks can be used to sync the database with the canonical models with the JSON data:

* `rails canonical_models:sync:all` (syncs all canonical models with JSON data)
* `rails canonical_models:sync:alchemical_properties` (syncs canonical alchemical properties with JSON data)
* `rails canonical_models:sync:powers` (syncs powers and abilities with JSON data)
* `rails canonical_models:sync:properties` (syncs canonical properties with JSON data)
* `rails canonical_models:sync:enchantments` (syncs canonical enchantments with JSON data)
* `rails canonical_models:sync:spells` (syncs canonical spells with JSON data)
* `rails canonical_models:sync:materials` (syncs canonical materials with JSON data)
* `rails canonical_models:sync:armor` (syncs canonical armours with JSON data)
* `rails canonical_models:sync:jewelry` (syncs canonical jewellery with JSON data)
* `rails canonical_models:sync:clothing` (syncs canonical clothing items with JSON data)
* `rails canonical_models:sync:ingredients` (sync canonical ingredients with JSON data)
* `rails canonical_models:sync:weapons` (sync canonical weapons with JSON data)
* `rails canonical_models:sync:staves` (sync canonical staves with JSON data)

These tasks sync the models with the attributes in the JSON files. The tasks are idempotent. If a model already exists in the database with a given name, it will be updated with the attributes given in the JSON data. This is also true of associations: if an association is found in the database then the corresponding model (or join model) will be updated with data from the JSON files. **The Rake tasks will also remove models and associations that exist in the database but are not present in the JSON data.** This behaviour can be disabled by setting the `preserve_existing_records` argument on the Rake tasks to `true` (or any value other than `false`):

```
bundle exec rails 'canonical_models:sync:all[true]'
```

This argument can also be set on the individual tasks:

```
bundle exec rails 'canonical_models:sync:properties[true]'
```

In addition to seeding the models, the Rake task also creates canonical associations - for example, adding enchantments to items that are canonically enchanted with one or more of the standard enchantments or smithing materials to armours. Because of this, tasks to sync apparel items list the one that syncs enchantments as prerequisites. Tasks to sync jewellery and armour items also require `canonical_models:sync:materials` as a prerequisite. (Clothing items don't have materials and are therefore only dependent on enchantments.) If the `preserve_existing_records` argument is set to `false` (which is its default value) when the Rake task is invoked, any associations with `dependent: :destroy` set will be destroyed along with any corresponding records not included in the JSON data. Additionally, associations that are not present in the JSON data will be destroyed as well.

### Running Rake Tasks in Production

To run the Rake tasks in production, use the `heroku run` CLI command from within this repo (you will need to log in to Heroku):
```
heroku login
heroku run bundle exec rails canonical_models:sync:all
```
