# Canonical Data

Canonical models are synced in the database from JSON data kept in the `/lib/tasks/canonical_models` directory. The models are stored in the database so that the JSON data, which consists of arrays of sometimes thousands of objects, don't have to be held in an in-memory data store. The JSON data in this repository are authoritative: where there is a discrepancy between the database and the JSON data, the JSON data should be considered correct and the database synced to them.

## Data Sources

Data in the JSON files have been exhaustively researched and compiled using sources including the following. This non-exhaustive list is provided to assist the reader in collecting further canonical data or correcting those which already exist.

* [The Elder Scrolls Wiki](https://elderscrolls.fandom.com/wiki/The_Elder_Scrolls_Wiki)
* [The Unofficial Elder Scrolls Pages](https://en.uesp.net/wiki/Main_Page)
* [The Elder Scrolls V: Skyrim Wiki Guide](https://www.ign.com/wikis/the-elder-scrolls-5-skyrim) (IGN)

Data have been collected in [these worksheets](https://docs.google.com/spreadsheets/d/1Vl3DasbrcbNwvuGSsrhzk6MByM4Q5WcQG0_sMijd380/edit?usp=sharing) in Google Sheets. **JSON data in the repo, not data in the worksheets, should be considered authoritative.** The data in the worksheets, while a useful reference, are known to be incomplete and are organised differently to the data in the JSON files (for example, standard enchanted armour items are kept in a separate spreadsheet from unenchanted or unique armour items but should be together in the JSON data).

## Data Structure

In order to work with the [`Canonical::Sync`](/docs/canonical_models/syncing-canonical-models.md) module that syncs the database with JSON data, the data need a particular structure as follows.

All JSON objects in the arrays (each of which represents a single model to be created or synced) must contain a key, `"attributes"` whose value is an object containing the _own attributes_ of the model to be created or synced with that object. The keys in this object must all be attributes defined on the database table for that model, and the values associated with those keys need to be compatible with the data type and validations of the corresponding database column.

For each object in the array, there should also be an array(s) of any associations that model has. The key pointing to these arrays should be the name of the association. For instance, if a model has associations called `:enchantments` and `:crafting_materials`, the keys pointing to arrays of those associations should also be called `"enchantments"` and `"crafting_materials"`. Each array should contain objects with the following:

* The [unique identifier](/docs/canonical_models/canonical-models.md#common-api) of the associated model
* Any attributes to be defined on the join model

The syncer will not create or update associated models in the database. Associated models must be populated first so the syncer can associate them using their unique identifier. If the table for associated models is empty, the syncer will raise an error; however, if the table is populated with any data, even if it is out of sync with JSON data, the syncer will base associations off the data in the database.

Since associated models are not created or updated as part of each sync, it is important to note that any attributes defined in objects in association arrays, other than the unique identifier of the associated model, will be defined on the join model, not on the associated model itself. Any changes to data for associated models must be made in the JSON data for those models themselves.

### Important Note on Item Codes

Codes representing particular items are not case sensitive in-game and are therefore listed using different casing (or inconsistent casing) in different sources. **Item codes in SIM are always upper-case.** Since items are generally looked up by unique identifier rather than primary key, it is critical that these codes be meticulously upcased when generating and cleansing JSON data. Failing to do can will result in duplicate item codes or failure to return a model that exists in the database but whose item code contains lower-case characters.

### Example

Here is an example of an object representing a `Canonical::JewelryItem` model:

```json
{
  "attributes": {
    "name": "Amulet of Mara",
    "item_code": "000C891B",
    "jewelry_type": "amulet",
    "unit_weight": 1,
    "quest_item": false,
    "magical_effects": null,
    "unique_item": false,
    "enchantable": false
  },
  "enchantments": [
    {
      "name": "Fortify Restoration",
      "strength": 10
    }
  ],
  "crafting_materials": []
}
```

In this example, notice that the object in the `"enchantments"` array includes the `"name"` of the enchantment (which is the unique identifier for that model) and the `"strength"` (which is defined on the join table and represents how strong the enchantment is _on this particular item_).

## Exporting CSVs

In some cases, you may want the JSON data in tabular format. You can obtain CSV files with the data using the Rake tasks defined [here](/lib/tasks/export_csvs.rake) in the `csv:export` namespace. The tasks will save CSV files in the `/lib/tasks/canonical_models` directory with filenames corresponding to the JSON file for that model. For example, weapons, which are kept in a JSON file called `canonical_weapons.json`, will likewise be exported to a CSV file called `canonical_weapons.csv`. The CSV files generated are gitignored and should not be committed. Instead, they can be used to populate a spreadsheet, enabling easy viewing of data, or editing data that will then be converted back to JSON form.

## Generating JSON Data

There are no Rake tasks or scripts in this repo that will generate and validate JSON data from CSV files. If you need to generate such data, you will need to write your own task to do it. These tasks may be committed to version control if and only if the CSV files from which they generate data follow the same schema as CSVs [exported](#exporting-csvs) from SIM. Note that all fields, even those with an empty value or a value of `null`, must be defined on each JSON object. See the [above example](#example), in which the `"magical_effects"` field is `null` and the `"crafting_materials"` association array is empty. The syncer will not work if all fields and associations are not defined.