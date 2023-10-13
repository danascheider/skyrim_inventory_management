# Canonical::Weapon

The `Canonical::Weapon` model represents a weapon.

## Enchantments

Weapons can be enchanted with enchantments via the `EnchantablesEnchantment` join model. Each weapon can have multiple enchantments associated. In-game items corresponding to canonical weapons with `enchantable` set to `true` may have new enchantments added by the user as well. (In addition to enchantments, the `magical_effects` field enables users to specify miscellaneous magical powers the weapon has.)
