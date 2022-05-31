# Syncing Canonical Models

For more information about SIM's canonical models, view the [other docs in this directory](/docs/canonical_models/README.md).

In order to easily maintain and correct canonical data in the database, the SIM backend uses several Rake tasks to sync the database with JSON data that lives in files in the `/lib/tasks/canonical_models` directory. These Rake tasks are powered by the [`Canonical::Sync`](/app/models/canonical/sync.rb) module. This module provides syncers that sync each type of canonical model based on the corresponding JSON file.

## Table of Contents

* [Rake Tasks](#rake-tasks)
  * [Running Rake Tasks in Production](#running-rake-tasks-in-production)
* [Syncers](#syncers)
* [Prerequisites](#prerequisites)
* [Logging](#logging)
* [Curating JSON Data](#curating-json-data)

## Rake Tasks

The following idempotent Rake tasks can be used to sync the database with the canonical models with the JSON data:

* `rails canonical_models:sync:all` (syncs all canonical models with JSON data)
* `rails canonical_models:sync:alchemical_properties` (syncs canonical alchemical properties with JSON data)
* `rails canonical_models:sync:armor` (syncs canonical armours with JSON data)
* `rails canonical_models:sync:books` (sync canonical books with JSON data)
* `rails canonical_models:sync:clothing` (syncs canonical clothing items with JSON data)
* `rails canonical_models:sync:enchantments` (syncs canonical enchantments with JSON data)
* `rails canonical_models:sync:ingredients` (sync canonical ingredients with JSON data)
* `rails canonical_models:sync:jewelry` (syncs canonical jewellery with JSON data)
* `rails canonical_models:sync:materials` (syncs canonical materials with JSON data)
* `rails canonical_models:sync:misc_items` (syncs canonical misc items with JSON data)
* `rails canonical_models:sync:potions` (syncs canonical potions with JSON data)
* `rails canonical_models:sync:powers` (syncs powers and abilities with JSON data)
* `rails canonical_models:sync:properties` (syncs canonical properties with JSON data)
* `rails canonical_models:sync:spells` (syncs canonical spells with JSON data)
* `rails canonical_models:sync:staves` (sync canonical staves with JSON data)
* `rails canonical_models:sync:weapons` (sync canonical weapons with JSON data)

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

## Syncers

There are two basic syncer classes, of which all other syncers are subclasses. The main `Canonical::Sync::Syncer` class syncs models that don't have associations to other canonical models, while the `Canonical::Sync::AssociationSyncer` class syncs those that do. The `AssociationSyncer` is itself a subclass of `Syncer`.

The entry point for the syncers is the `Canonical::Sync::perform` method. This method takes two arguments: `model` - a symbol indicating which model should be synced - and `preserve_existing_records` - a boolean indicating whether models and assocations that are present in the database but not the JSON data should be removed or not. The default of the latter is `false` - in other words, by default, models that are present in the database but not the JSON data will be removed when the syncer runs. Note that the `Canonical::Sync::Ingredients` syncer never preserves associations that are in the database but not the JSON data. This is because every ingredient has four and only four alchemical properties, so any that exist in the database when syncing will cause conflicts with those in the JSON data.

Models that are in both the database and the JSON data will be matched by their unique identifier and all other attributes will then be updated with the attributes in the JSON data.

Syncers make model updates inside ActiveRecord transactions. If any validation or other error is raised during sync, the entire sync for that model is rolled back.

## Prerequisites

Certain models can't be synced until their associations are already present in the database. Syncers check whether associated models are present in the database prior to sync, raising a `Canonical::Sync::PrerequisiteNotMetError` if any of the associated tables are empty. **Syncers only check the presence of data in associated tables - they do not check whether that data is up-to-date with the corresponding JSON files.**

The following models have prerequisites:

| model                     | prerequisites                                 |
| ------------------------- | --------------------------------------------- |
| `Canonical::Armor`        | `Enchantment`, `Canonical::Material`          |
| `Canonical::Book`         | `Canonical::Ingredient`                       |
| `Canonical::ClothingItem` | `Enchantment`                                 |
| `Canonical::Ingredient`   | `AlchemicalProperty`                          |
| `Canonical::JewelryItem`  | `Enchantment`, `Canonical::Material`          |
| `Canonical::Potion`       | `AlchemicalProperty`                          |
| `Canonical::Staff`        | `Spell`, `Power`                              |
| `Canonical::Weapon`       | `Enchantment`, `Power`, `Canonical::Material` |

The only model that both has a prerequisite and is itself a prerequisite to another model is `Canonical::Ingredient`.

Although running a syncer will not automatically sync prerequisites, the Rake tasks for individual models do have prerequisites that will run first, ensuring that prerequisites will never be an issue when models are synced through the tasks. The Rake task to sync all models will also ensure prerequisite models are synced before the models that require them.

## Logging

Syncers provide detailed info and error logging. The logging is done using the Rails logger, meaning it will be logged to the main log for whichever environment the syncer runs in.

## Curating JSON Data

Information about the JSON data, its structure, generating and curating it is available in the [docs on canonical data](/docs/canonical_models/canonical-data.md).