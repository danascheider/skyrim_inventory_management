# In-Game Items

The following non-[canonical](/docs/canonical_models/README.md) in-game item models exist in the SIM database:

* [`Armor`](/app/models/armor.rb): armour items corresponding to `Canonical::Armor` pieces
* [`ClothingItem`](/app/models/clothing_item.rb): clothing items that are not armour or jewellery, corresponding to `Canonical::ClothingItem`s
* [`Ingredient`](/app/models/ingredient.rb): ingredients corresponding to the `Canonical::Ingredient` class
* [`JewelryItem`](/app/models/jewelry_item.rb): jewelry items corresponding to the `Canonical::JewelryItem` class
* [`IngredientsAlchemicalProperty`](/app/models/ingredients_alchemical_property.rb): join model between `Ingredient` and `AlchemicalProperty` models

Non-canonical in-game items represent individual item instances. For the purpose of inventory lists, they can also represent sets of items with identical characteristics whose quantities are then implied by the `quantity` field on the inventory item. (Note that, at this writing, inventory list functionality is not yet fully implemented.)

## Common Characteristics

### Matching with Canonical Models

Every in-game item has to correspond to at least one canonical model. Because not all attributes are pertinent to users and not all should be able to be set by them, non-canonical models do not have the same fields and associations as the canonical models. Instead, non-canonical models include the subset of canonical fields that are visible to or discoverable by players.

When an in-game item is created, it is validated to ensure that it has at least one potential canonical match. These matches are based on fields set on the non-canonical model, or in [some cases](/docs/in_game_items/ingredient.md), associations that are present on that model; in other words, fields that are `nil` on the non-canonical model are not considered for the match. Only fields set to a non-`nil` value, or associations that have been created on the non-canonical model, must match the canonical model.

If the in-game item matches exactly one canonical model, that model is set as the `canonical_<model>` for that item. If there are no matching canonical models, validation fails.

### Auto-Populating Fields

Some fields and associations on canonical models are either not visible to users (such as whether an item is purchasable), not relevant to them (such as item code), or discoverable by them (such as the alchemical properties of an ingredient). Non-canonical item models contain only the fields and associations that are either visible to or discoverable by users.

When a non-canonical item is matched to a single canonical model, fields and associations that are visible to the user (i.e., those like weight that the user can automatically see just because they've seen the item) are automatically populated or created on the non-canonical item. Certain associations, such as `crafting_materials` and `tempering_materials` on weapons and armour items, will not differ for separate instances and are therefore delegated to the canonical model to prevent the need to create redundant models.

Canonical models are initially found using a case-insensitive matching by name. For this reason, the name of the non-canonical model is also updated to match the casing of the canonical model's name.
