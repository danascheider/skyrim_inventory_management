## Weapon

The `Weapon` model represents in-game items of the `Canonical::Weapon` type.

## Matching Attributes

`Weapon` models are matched to `Canonical::Weapon` models using the following fields:

* `name` (case-insensitive)
* `magical_effects` (case-insensitive)
* `unit_weight`
* `category`
* `weapon_type`

## Associations

Because `Weapon` models may (at least theoretically) have user-added enchantments in addition to those present on the canonical model, the `Weapon` model has its own associations to `EnchantablesEnchantment` and `Enchantment`. The canonical model's enchantments will automatically be added to the `Weapon` model after save if it has a single matching `Canonical::Weapon` model. If additional enchantments are added, the `EnchantablesEnchantment` model validates that the canonical weapon either has the same enchantment or is `enchantable` before the join model is allowed to be created.

Like the [`Armor` model](/docs/in_game_items/armor.md), a weapon's `crafting_materials` and `tempering_materials` don't differ from the canonical model, so `Weapon`s don't have their own associations and instead pull crafting and tempering materials from the `Canonical::Weapon` model if they have one.

## Auto-Populated Fields

Weapons don't have any attributes that are initially hidden from users and discoverable as they play the game. For that reason, all matching attributes are set and enchantments added as soon as a single canonical model is able to be identified.
