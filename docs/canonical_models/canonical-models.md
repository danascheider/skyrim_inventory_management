# Canonical Models

The following canonical models exist in the SIM database:

* [`Canonical::Armor`](/app/models/canonical/armor.rb): actual armor pieces available in the game
* [`Canonical::Book`](/app/models/canonical/book.rb): actual books, letters, recipes, and journals available in the game; includes Elder Scrolls; additional information about this model is available [here](/docs/models/canonical-book.md)
* [`Canonical::ClothingItem`](/app/models/canonical/clothing_item.rb): actual clothing items available in the game; includes mages' robes as well as plain clothes
* [`Canonical::Ingredient`](/app/models/canonical/ingredient.rb): actual ingredients available in the game; has many-to-many association to `AlchemicalProperty`, which it can have no more than 4 of without causing a validation error
* [`Canonical::JewelryItem`](/app/models/canonical/jewelry_item.rb): actual jewelry items available in-game, including both generic and unique pieces
* [`Canonical::RawMaterial`](/app/models/canonical/raw_material.rb): actual building and smithing materials present in the game
* [`Canonical::MiscItem`](/app/models/canonical/misc_item.rb): miscellaneous items occurring in the game that may be either useful or decorative
* [`Canonical::Potion`](/app/models/canonical/potion.rb): potions that may be purchased or found in-game (does not include player-created potions, which can be validated using only alchemical properties without needing an additional canonical model)
* [`Canonical::Property`](/app/models/canonical/property.rb): actual properties (homes) the player character can own in the game
* [`Canonical::Staff`](/app/models/canonical/staff.rb): actual staves the player character can acquire in the game
* [`Canonical::Weapon`](/app/models/canonical/weapon.rb): actual weapons the player character can acquire in the game

These models represent prototypes of objects users may find in-game and enter into their inventory.The data from which the database is synced live in JSON files in the `/lib/tasks/canonical_models` directory. These JSON files contain attributes for each model that should exist in the database (whether in development or production).

There are additional models that can also be considered canonical, but are not namespaced under the `Canonical` module. These models are named differently because their function is to be discovered in the game and associated to objects the user finds or creates, not to validate data the user has entered. These models are:

* [`AlchemicalProperty`](/app/models/alchemical_property.rb): actual properties of ingredients or potions that exist in the game
* [`Enchantment`](/app/models/enchantment.rb): actual enchantments that exist in the game
* [`Spell`](/app/models/spell.rb): actual spells that exist in the game
* [`Power`](/app/models/power.rb): actual powers and abilities that exist in the game

Note that the lists above do not include join tables for the `has_many, :through` relationships amongst the models listed, although these are similarly synced in the SIM database with data from the game. These include:

* [`Canonical::Material`](/app/models/canonical/material.rb): This polymorphic join table associates canonical materials with any items that are able to be crafted or tempered using those materials, including armour pieces, jewellery, and weapons, adding a field called `quantity` for the quantity of a given material needed to craft or temper that particular item
* [`Canonical::PotionsAlchemicalProperty`](/app/models/canonical/potions_alchemical_property.rb): This join table links canonical potions with their alchemical properties, setting a `strength` and `duration` on the association
* [`Canonical::PowerablesPower`](/app/models/canonical/powerables_power.rb): This polymorphic join table associates powers with any objects enchanted with them, including weapons and staves, adding no additional fields to the join table
* [`Canonical::RecipesIngredient`](/app/models/canonical/recipes_ingredient.rb): This join table links canonical books that are recipes with the ingredients specified in the recipe; there are no fields on this table other than foreign keys and timestamps
* [`Canonical::StavesSpell`](/app/models/canonical/staves_spell.rb): This join table links enchanted staves to the spells they are enchanted with, adding a `strength` field in case the strength of the spell on the staff differs from the base strength of the spell
* [`Canonical::IngredientsAlchemicalProperty`](/app/models/canonical/ingredients_alchemical_property.rb): Associates canonical ingredients with the `AlchemicalProperty` model; no more than 4 can be created for each ingredient before a validation error is raised; additional docs available [here](/docs/canonical_models/canonical-ingredients-alchemical-property.md)
* [`RecipesCanonicalIngredient`](/app/models/recipes_canonical_ingredient.rb): Associates canonical and non-canonical recipe books to the canonical ingredients required to prepare the recipe; additional docs are available [here](/docs/canonical_models/recipes-canonical-ingredient.md)

Note that weapons and armour items have multiple associations to the same table - canonical materials - but the associations are separate since materials required to improve an item and those required to create it are distinct. If materials associations are blank, it means the item in question can't be crafted or improved.

There is an additional join model that is not in the `Canonical` namespace and is used for both canonical and non-canonical models:

* [`EnchantablesEnchantment`](/app/models/enchantables_enchantment.rb): This polymorphic join table associates enchantments with any enchantable items, including armours, jewellery, clothing items, and weapons, adding a field called `strength` for the strength of the enchantment on that particular item

## Common API

### Class API

All canonical models, not including join tables, must have a class method, `::unique_identifier`, defined, which returns a symbol that is the column (other than the primary key) to be used as the unique identifier for that model. If a table includes an `:item_code` column, this will be the unique identifier. For models that don't include an item code, another unique identifier, such as `:name`, may be used. The `::unique_identifier` method is called in the [syncer](/app/models/canonical/sync/syncer.rb) to indicate how models being synced should be uniquely identified and matched with corresponding records already existing in the database. The Rake tasks that [sync the canonical models](/docs/canonical_models/syncing-canonical-models.md) will not function without this method defined.

### Instance API

While there are no fields common to every canonical model, there are a few that are worth mentioning as common to most. These fields are present on every canonical model except `Canonical::Property` and `Canonical::RawMaterial`. (They are not defined on the pseudo-canonical models `AlchemicalProperty`, `Spell`, `Enchantment`, and `Power`.) Each of these columns is a boolean and is required to have a non-`NULL` value.

#### `add_on`

The `add_on` field indicates whether the item is part of the base game or an add-on/DLC. If the value is `"base"`, the item is included with the base game. Currently-supported add-on values are:

* `base`
* `dragonborn`
* `dawnguard`
* `hearthfire`

#### `max_quantity`

The `max_quantity` integer field represents the maximum quantity of a given item obtainable in the game. A `NULL` value indicates that there is no maximum. This is the most common value since most items are either potentially purchasable, dropped as random loot, or respawn in one or more locations. Note that the `Canonical::Property` model does not include this field.

#### `purchasable`

The `purchasable` field indicates whether an item can be purchased from a merchant or other NPC. Having a `purchasable` value of `true` does not mean that an item will be consistently or frequently available from merchants - it only means that it's worth checking with merchants if you're looking for it.

#### `collectible`

The `collectible` field (boolean) indicates that an item is both obtainable (like all items included in SIM) and can be retained after any associated quest concludes. This value is set to `false` if an item must be used up or relinquished in the course of a quest (unless it is obtainable after, such as by killing the NPC it was given to and looting the body). Note that the `Canonical::Property` model does not include this field.

#### `unique_item`

The `unique_item` field is set to `true` on items that only occur at one location in the game. That location cannot be a merchant, random loot, or random drops. When `unique_item` is set to `true` on a canonical model, SIM will prevent users from creating multiple in-game items matching that canonical model for the same associated `game`. Note that items that respawn can still be considered unique if they adhere to the criteria above. There is planned work to change this.

#### `rare_item`

The `rare_item` field indicates whether an item is rare. Unique items are also rare, and there is a validation ensuring that they are. The definition of a rare item varies slightly by the model in question (and, also, whether the item is consumable - this includes canonical ingredients, potions, arrows, and bolts). In general, with these exceptions, rare items are defined as:

* Items that are not purchasable and are available in fewer than 10 fixed locations in the game
* Items that are purchasable and are available in fewer than 3 other fixed locations in the game

##### Purchasability of Rare Items

As noted above, the `purchasable` designation indicates only that an item is _potentially_ available from at least one vendor at some point in the game. The designation does not mean that the item is consistently or reliably available for sale. In some cases, items are not available before certain levels, or items may become available for purchase only after a certain quest has been started or finished. In the case of ingredients, some require the [Merchant perk](https://en.uesp.net/wiki/Skyrim:Speech#Skill_Perks) to purchase (this is indicated by the special `purchase_requires_perk` field on the `Canonical::Ingredient` model).

If an item is readily available from more than one vendor, that item is automatically not rare. For items that are available inconsistently or from only one vendor, these items may also be rare depending on the number of other locations they can be found in as described above.

The only exceptions to these rules are items that are consumable, including arrows, bolts, [ingredients](/docs/canonical_models/canonical-ingredient.md#treatment-of-rare-ingredients), and potions. In these cases, a more complex calculus goes into determining whether they are rare, including the subjective experience of how hard they seem to be to find when playing the game.

#### `quest_item`

In Skyrim, a quest item is considered to be an item that is required to complete a quest. This is distinct from a quest reward, which is an item obtained by completing a quest. In SIM, both of these types of items are designated with the `quest_item` field. Quest rewards are additionally designated with the `quest_reward` field. **An item that is a quest reward will not be designated as a `quest_item` if there is any other way of obtaining the item in the game.**

#### `quest_reward`

Additionally, items that are not quest rewards but are only found or able to be purchased after starting or completing a certain quest or questline are not designated as quest items in SIM. While quest rewards that can be obtained by other means as well will not be labeled `quest_item`s, they will still have the `quest_reward` field set to `true`.

## Syncing Canonical Models

For more information about syncing canonical models and the `Canonical::Sync` module, which powers the Rake tasks that sync the models, see the [docs for that module](/docs/canonical_models/syncing-canonical-models.md).
