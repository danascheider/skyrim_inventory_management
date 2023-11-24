# Jewelry Item

The `JewelryItem` model represents in-game items of the `Canonical::JewelryItem` class. These are items classified as clothing that are not better classified as [`Armor`](/docs/in_game_items/armor.md) or [`ClothingItem`s](/docs/in_game_items/clothing-item.md).

## Matching Attributes

`JewelryItem` models are matched to `Canonical::JewelryItem` models using the following fields:

* `name`
* `unit_weight`
* `magical_effects`

Since `JewelryItem` models can also be enchanted, they are also matched to canonical models based on any enchantments they have. Enchantments must match both the `enchantment_id` and the `strength` (if present) of the enchantment on the canonical model.

## Associations

Because `JewelryItem` models may (at least theoretically) have user-added enchantments in addition to those present on the canonical model, the `JewelryItem` model has its own associations to `EnchantablesEnchantment` and `Enchantment`. Enchantments that exist on the canonical model will be automatically added to the `JewelryItem` model when it is saved and a single matching `Canonical::JewelryItem` has been identified. Enchantments added automatically in this way will have the `added_automatically` attribute set to true on the `EnchantablesEnchantment` join model. For other enchantments, this value will be set to `false`. Automatically added enchantments are not used in the algorithm that matches `Canonical::JewelryItem` models. Additionally, they will be removed if the canonical match changes or the association is set to `nil`.

The `Canonical::JewelryItem` model has associations to `crafting_materials` that will be the same for all non-canonical models that inherit from a given canonical model. For this reason, calling `#crafting_materials` on a non-canonical `JewelryItem` model will return the crafting materials for its corresponding `Canonical::JewelryItem` if one exists.

## Auto-Populated Fields

Jewelry items don't have any attributes that are initially hidden from users and discoverable as they play the game. For that reason, all matching attributes are set and enchantments added as soon as a single canonical model is able to be identified.
