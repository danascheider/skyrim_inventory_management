# Canonical Models

The following canonical models exist in the SIM database:

* [`Canonical::Armor`](/app/models/canonical/armor.rb): actual armor pieces available in the game
* [`Canonical::Book`](/app/models/canonical/book.rb): actual books, letters, recipes, and journals available in the game; includes Elder Scrolls; additional information about this model is available [here](/docs/models/canonical-book.md)
* [`Canonical::ClothingItem`](/app/models/canonical/clothing_item.rb): actual clothing items available in the game; includes mages' robes as well as plain clothes
* [`Canonical::Ingredient`](/app/models/canonical/ingredient.rb): actual ingredients available in the game; has many-to-many association to `AlchemicalProperty`, which it can have no more than 4 of without causing a validation error
* [`Canonical::JewelryItem`](/app/models/canonical/jewelry_item.rb): actual jewelry items available in-game, including both generic and unique pieces
* [`Canonical::Material`](/app/models/canonical/material.rb): actual building and smithing materials present in the game
* [`Canonical::Property`](/app/models/canonical/property.rb): actual properties (homes) the player character can own in the game
* [`Canonical::Weapon`](/app/models/canonical/weapon.rb): actual weapons the player character can acquire in the game
* [`Canonical::Staff`](/app/models/canonical/staff.rb): actual staves the player character can acquire in the game

These models represent prototypes of objects users may find in-game and enter into their inventory.The data from which the database is synced live in JSON files in the `/lib/tasks/canonical_models` directory. These JSON files contain attributes for each model that should exist in the database (whether in development or production).

There are additional models that can also be considered canonical, but are not namespaced under the `Canonical` module. These models are named differently because their function is to be discovered in the game and associated to objects the user finds or creates, not to validate data the user has entered. These models are:

* [`AlchemicalProperty`](/app/models/alchemical_property.rb): actual properties of ingredients or potions that exist in the game
* [`Enchantment`](/app/models/enchantment.rb): actual enchantments that exist in the game
* [`Spell`](/app/models/spell.rb): actual spells that exist in the game
* [`Power`](/app/models/power.rb): actual powers and abilities that exist in the game

Note that the lists above do not include join tables for the `has_many, :through` relationships amongst the models listed, although these are similarly synced in the SIM database with data from the game. These include:

* [`Canonical::EnchantablesEnchantment`](/app/models/canonical/enchantables_enchantment.rb): This polymorphic join table associates enchantments with any enchantable items, including armours, jewellery, clothing items, and weapons, adding a field called `strength` for the strength of the enchantment on that particular item
* [`Canonical::CraftablesCraftingMaterial`](/app/models/canonical/craftables_crafting_material.rb): This polymorphic join table associates canonical materials with any items that are able to be crafted using those materials, including armours, jewellery, and weapons, adding a field called `quantity` for the quantity of a given material needed to craft that particular item
* [`Canonical::PowerablesPower](/app/models/canonical/powerables_power.rb): This polymorphic join table associates powers with any objects enchanted with them, including weapons and staves, adding no additional fields to the join table
* [`Canonical::RecipesIngredient`](/app/models/canonical/recipes_ingredient.rb): This join table links canonical books that are recipes with the ingredients specified in the recipe; there are no fields on this table other than foreign keys and timestamps
* [`Canonical::StavesSpell](/app/models/canonical/staves_spell.rb): This join table links enchanted staves to the spells they are enchanted with, adding a `strength` field in case the strength of the spell on the staff differs from the base strength of the spell
* [`Canonical::TemperablesTemperingMaterial`](/app/models/canonical/temperables_tempering_material.rb): This polymorphic join table associates canonical materials with any items that are able to be tempered using those materials, including armours and weapons, adding a field called `quantity` for the quantity of a given material needed to temper that particular item
* [`Canonical::IngredientsAlchemicalProperty](/app/models/canonical/ingredients_alchemical_property.rb): Associates canonical ingredients with the `AlchemicalProperty` model; no more than 4 can be created for each ingredient before a validation error is raised; additional docs available [here](/docs/canonical_models/canonical-ingredients-alchemical-property.md)

Note that weapons and armour items have multiple associations to the same table - canonical materials - but the associations are separate since materials required to improve an item and those required to create it are distinct. If materials associations are blank, it means the item in question can't be crafted or improved.

## Common API

All canonical models, not including join tables, must have a class method, `::unique_identifier`, defined, which returns a symbol that is the column (other than the primary key) to be used as the unique identifier for that model. If a table includes an `:item_code` column, this will be the unique identifier. For models that don't include an item code, another unique identifier, such as `:name` may be used. The `::unique_identifier` method is called in the [syncer](/app/models/canonical/sync/syncer.rb) to indicate how models being synced should be uniquely identified and matched with corresponding records existing in the database. The Rake tasks that [sync the canonical models](/docs/canonical_models/syncing-canonical-models.md) will not function without this method defined.

## Syncing Canonical Models

For more information about syncing canonical models and the `Canonical::Sync` module, which powers the Rake tasks that sync the models, see the [docs for that module](/docs/canonical_models/syncing-canonical-models.md).
