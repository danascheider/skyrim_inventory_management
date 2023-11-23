# Armor

The `Armor` model represents in-game items of the `Canonical::Armor` type.

## Matching Attributes

`Armor` models are matched to `Canonical::Armor` models using the following fields:

* `name`
* `unit_weight`
* `weight`
* `magical_effects`

If an `Armor` model has enchantments, its enchantments are also matched against any canonical matches. To match a canonical model, one of two things has to be the case:

1. All enchantments on the in-game item match in both `enchantment_id` and `strength` (if present)
2. The canonical model has its `enchantable` attribute set to `true`, indicating that user-added enchantments are allowed

## Associations

Because `Armor` models may (at least theoretically) have user-added enchantments in addition to those present on the canonical model, the `Armor` model has its own associations to `EnchantablesEnchantment` and `Enchantment`. The canonical model's enchantments will automatically be added to the `Armor` model when it is saved and has a single matching `Canonical::Armor` model. Enchantments added automatically in this way will have `added_automatically` set to `true` (this attribute is set on the `EnchantablesEnchantment` join model). Otherwise, it will be set to `false`. Automatically added associations will not be considered when matching `Armor` models to `Canonical::Armor` models.

The `Canonical::Armor` model has associations to `tempering_materials` and `crafting_materials` that will be the same for all non-canonical models that inherit from a given canonical model. For this reason, calling `#crafting_materials` or `#tempering_materials` on a non-canonical `Armor` model will return the crafting materials or tempering materials for its corresponding `Canonical::Armor` if one exists.

## Auto-Populated Fields

Armor pieces don't have any attributes that are initially hidden from users and discoverable as they play the game. For that reason, all matching attributes are set and enchantments added as soon as a single canonical model is able to be identified.
