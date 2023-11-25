# In-Game Items

The following non-[canonical](/docs/canonical_models/README.md) in-game item models exist in the SIM database:

* [`Armor`](/app/models/armor.rb): armour items corresponding to `Canonical::Armor` pieces
* [`ClothingItem`](/app/models/clothing_item.rb): clothing items that are not armour or jewellery, corresponding to `Canonical::ClothingItem`s
* [`Ingredient`](/app/models/ingredient.rb): ingredients corresponding to the `Canonical::Ingredient` class
* [`IngredientsAlchemicalProperty`](/app/models/ingredients_alchemical_property.rb): join model between `Ingredient` and `AlchemicalProperty` models
* [`JewelryItem`](/app/models/jewelry_item.rb): jewelry items corresponding to the `Canonical::JewelryItem` class
* [`MiscItem`](/app/models/misc_item.rb): miscellaneous items corresponding to the `Canonical::MiscItem` class
* [`Potion`](/app/models/potion.rb): potions corresponding to the `Canonical::Potion` class, as well as user-created potions
* [`PotionsAlchemicalProperty`](/app/models/potions_alchemical_property.rb): join model between `Potion` and `AlchemicalProperty` models
* [`Property`](/app/models/property.rb): houses and properties corresponding to the `Canonical::Property` model
* [`Staff`](/app/models/staff.rb): staves corresponding to the `Canonical::Staff` model
* [`Weapon`](/app/models/weapon.rb): weapons corresponding to the `Canonical::Weapon` model

Non-canonical in-game items represent individual item instances. For the purpose of inventory lists, they can also represent sets of items with identical characteristics whose quantities are then implied by the `quantity` field on the inventory item. (Note that, at this writing, inventory list functionality is not yet fully implemented.)

## Inheritance

With the exception of `Potion` and `Property`, which have unique considerations, and join models, all other in-game item models inherit from `InGameItem`, an abstract superclass that provides all the common functionality below. Four models - `Armor`, `ClothingItem`, `JewelryItem`, and `Weapon` - also inherit from `EnchantedInGameItem`, an abstract subclass of `InGameItem` that handles logic around adding, removing, an matching on enchantments.

## Common Characteristics

### Matching with Canonical Models

Every in-game item has to correspond to at least one canonical model. Because not all attributes are directly pertinent to users and not all should be able to be set by them, non-canonical models do not have the same fields and associations as the canonical models. Instead, non-canonical models include the subset of canonical fields that are visible to or discoverable by players.

When an in-game item is saved, it is validated to ensure that it has at least one potential canonical match. These matches are based on fields set on the non-canonical model, or in [some cases](/docs/in_game_items/ingredient.md), associations that are present on that model; in other words, fields that are `nil` on the non-canonical model are not considered for the match. Only fields set to a non-`nil` value, or associations that have been created on the non-canonical model, must match the canonical model.

If the in-game item matches exactly one canonical model, that model is set as the `canonical_<model>` for that item. If there are no matching canonical models, validation fails. If the in-game item model is updated such that it no longer matches the currently-associated canonical model, the matching algorithm will be run again. If the update results in ambiguous, or no, canonical matches, the `canonical_<model>_id` will be set to `nil`. As before, ambiguous matches are allowed, but validation will fail if there are no matches (other than for [potions](/docs/in_game_items/potion.md), which can be player-created and don't always have canonical matches).

### Auto-Populating Fields

Some fields and associations on canonical models are either not visible to users (such as whether an item is purchasable), not relevant to them (such as item code), or discoverable by them (such as the alchemical properties of an ingredient). Non-canonical item models contain only the fields and associations that are either visible to or discoverable by users.

When a non-canonical item is matched to a single canonical model, fields and associations that are visible to the user (i.e., those like weight that the user can automatically see just because they've seen the item) are automatically populated or created on the non-canonical item. Certain associations, such as `crafting_materials` and `tempering_materials` on weapons and armour items, will not differ for separate instances and are therefore delegated to the canonical model to prevent the need to create redundant models.

Canonical models are initially found using a case-insensitive matching by name (or `title` and `title_variants` for books). For this reason, the name of the non-canonical model is also updated to match the casing of the canonical model's name.
