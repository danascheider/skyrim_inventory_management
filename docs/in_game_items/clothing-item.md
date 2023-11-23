# Clothing Item

The `ClothingItem` model represents in-game clothing items that are not armour or jewellery, backed by the `Canonical::ClothingItem` model.

## Matching Attributes

`ClothingItem` models are matched to `Canonical::ClothingItem` models using the following fields:

* `name`
* `unit_weight`
* `magical_effects`

In addition to these, `ClothingItem` models are matched to canonicals based on any enchantments they may have. In order for a canonical model to match a `ClothingItem` with enchantments, one of the following must be true for all enchantments on the in-game item:

1. The canonical model must have the same enchantment at the same strength, or
2. The canonical model must have `enchantable` set to `true`, enabling user-added enchantments

## Associations

Because `ClothingItem` models may (at least theoretically) have user-added enchantments in addition to those present on the canonical model, the `ClothingItem` model has its own associations to `EnchantablesEnchantment` and `Enchantment`. The canonical model's enchantments will automatically be added to the `ClothingItem` model when it is saved and has a single matching `Canonical::ClothingItem` model. Enchantments added automatically in this way will have `added_automatically` set to `true` on the `EnchantablesEnchantment` join model. Other enchantments will have this attribute set to `false`. Automatically added enchantments will not be considered when matching with a `Canonical::ClothingItem`.
