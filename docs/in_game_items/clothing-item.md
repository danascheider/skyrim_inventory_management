# Clothing Item

The `ClothingItem` model represents in-game clothing items that are not armour or jewellery, backed by the `Canonical::ClothingItem` model.

## Matching Attributes

`ClothingItem` models are matched to `Canonical::ClothingItem` models using the following fields:

* `name`
* `unit_weight`
* `magical_effects`

## Associations

Because `ClothingItem` models may (at least theoretically) have user-added enchantments in addition to those present on the canonical model, the `ClothingItem` model has its own associations to `EnchantablesEnchantment` and `Enchantment`. The canonical model's enchantments will automatically be added to the `ClothingItem` model when it is saved and has a single matching `Canonical::ClothingItem` model.
