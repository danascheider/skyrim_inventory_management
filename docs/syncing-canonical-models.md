# Syncing Canonical Models

For more information about SIM's canonical models, view the [canonical model docs](/docs/canonical-models.md).

In order to easily maintain and correct canonical data in the database, the SIM backend uses several Rake tasks to sync the database with JSON data that lives in files in the `/lib/tasks/canonical_models` directory. These Rake tasks are powered by the [`Canonical::Sync`](/app/models/canonical/sync.rb) module. This module provides syncers that sync each type of canonical model based on the corresponding JSON file.

## Syncers

There are two basic syncer classes, of which all other syncers are subclasses. The main `Canonical::Sync::Syncer` class syncs models that don't have associations to other canonical models, while the `Canonical::Sync::AssociationSyncer` class syncs those that do. The `AssociationSyncer` is itself a subclass of `Syncer`.

The entry point for the syncers is the `Canonical::Sync::perform` method. This method takes two arguments: `model` - a symbol indicating which model should be synced - and `preserve_existing_records` - a boolean indicating whether models and assocations that are present in the database but not the JSON data should be removed or not. The default of the latter is `false` - in other words, by default, models that are present in the database but not the JSON data will be removed when the syncer runs. Note that the `Canonical::Sync::Ingredients` syncer never preserves associations that are in the database but not the JSON data. This is because every ingredient has four and only four alchemical properties, so any that exist in the database when syncing will cause conflicts with those in the JSON data.

Models that are in both the database and the JSON data will be matched by their unique identifier and all other attributes will then be updated with the attributes in the JSON data.

Syncers make model updates inside ActiveRecord transactions. If any validation or other error is raised during sync, the entire sync for that model is rolled back.

## Prerequisites

Certain models can't be synced until their associations are already present in the database. Syncers check whether associated models are present in the database prior to sync, raising a `Canonical::Sync::PrerequisiteNotMetError` if any of the associated tables are empty. **Syncers only check the presence of data in associated tables - they do not check whether that data is up-to-date with the corresponding JSON files.**

The following models have prerequisites:

| model                   | prerequisites                    |
| ----------------------- | -------------------------------- |
| Canonical::Armor        | Enchantment, Canonical::Material |
| Canonical::ClothingItem | Enchantment                      |
| Canonical::Ingredient   | AlchemicalProperty               |
| Canonical::JewelryItem  | Enchantment, Canonical::Material |
| Canonical::Weapon       | Enchantment, Canonical::Material |

Currently, none of the models that are prerequisites for other models have their own prerequisites.

Although running a syncer will not automatically sync prerequisites, the Rake tasks for individual models do have prerequisites that will run first, ensuring that prerequisites will never be an issue when models are synced through the tasks.

## Logging

Syncers provide detailed info and error logging. The logging is done using the Rails logger, meaning it will be logged to the main log for whichever environment the syncer runs in.

## Curating JSON Data

The JSON data in this repo represents every relevant canonical model known in Skyrim. This [Google Sheet](https://docs.google.com/spreadsheets/d/1Vl3DasbrcbNwvuGSsrhzk6MByM4Q5WcQG0_sMijd380/edit?usp=sharing) contains data about some of these models, which has been obtained through exhaustive research on sites like the [Elder Scrolls Wiki](https://elderscrolls.fandom.com/wiki/The_Elder_Scrolls_Wiki) and the [Unofficial Elder Scrolls Pages](https://en.uesp.net/wiki/Main_Page), among others. These spreadsheets cannot be turned into JSON data without some manipulation, however, and the data contained in them may not be complete or include all fields. The data contained in the existing JSON files in this repo should be considered authoritative, with the caveat that errors are always possible.

Syncers expect JSON data to be in a particular format. Each file should contain an array of JSON objects. Each object should have an `"attributes"` key, with an object including the attributes and values that should be defined on that model instance. For each of the model's associations, there should be a key with that association name with an array of associations. For example, the `Canonical::Ingredient` JSON file would contain an array of objects. Each object would include an `"attributes"` object with attributes like the name and item code of each ingredient. It would also then include an `"alchemical_properties"` array with relevant data on the associations. This data should include the association model's unique identifier (`item_code` if present, otherwise generally `name`) and any properties that need to be added to the join model - in this case, the priority of the property for the given ingredient and any multipliers. This is what the data should look like:

```json
{
  "attributes": {
    "name": "Abecean Longfin",
    "item_code": "00106E1B",
    "unit_weight": 0.5,
    "unique_item": false,
    "quest_item": false
  },
  "alchemical_properties": [
    {
      "priority": 1,
      "name": "Weakness to Frost",
      "strength_modifier": null,
      "duration_modifier": null
    },
    {
      "priority": 2,
      "name": "Fortify Sneak",
      "strength_modifier": null,
      "duration_modifier": null
    },
    {
      "priority": 3,
      "name": "Weakness to Poison",
      "strength_modifier": null,
      "duration_modifier": null
    },
    {
      "priority": 4,
      "name": "Fortify Restoration",
      "strength_modifier": null,
      "duration_modifier": null
    }
  ]
}
```

### Data Standardisation and Cleansing

Any changes to the JSON data should be made with standardisation rules in mind, as well as the requirements imposed by validations on the models in question.

#### Unique Identifiers

Every canonical model class has a unique identifier. For items that have item codes, the item code is the unique identifier. For other models, it is `name` or another attribute. (Each canonical model class defines a `unique_identifier` class method indicating what this field is for that model.) Care must be taken to ensure that this identifier is present in every record in the JSON data. There should also be a validator in the model class to ensure no record is saved without this identifier value.

#### Item Codes

Item codes in-game are case-insensitive. However, in SIM, all item codes should be upcased in JSON data. Failure to upcase item codes can result in duplicate "phantom" models and missing associations when lookups assume an upcased item code.

#### Associations

Association objects should always include the association's unique identifier as a key. If this is an item code, it must be upcased. Properties on association objects other than this identifier will be interpreted as attributes to be set on the join model. Because associated models are not created as part of a sync - only retrieved from the database using their unique identifier - additional attributes for the associated model itself should not be included in the JSON. Any changes to be made to an associated model should instead be made to the JSON data for that model class.