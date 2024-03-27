# Canonical::Weapon

The `Canonical::Weapon` model represents a weapon.

## Enchantments

Weapons can be enchanted with enchantments via the `EnchantablesEnchantment` join model. Each weapon can have multiple enchantments associated. In-game items corresponding to canonical weapons with `enchantable` set to `true` may have new enchantments added by the user as well. (In addition to enchantments, the `magical_effects` field enables users to specify miscellaneous magical powers the weapon has.)

## Crafting Materials

Standard, non-enchanted weapons may typically be crafted at a forge or anvil (given the right materials and perks). The required materials to craft each item may be `Canonical::RawMaterial` models but may also be `Canonical::Ingredient`s or even other `Canonical::Weapon`s. These associations are made using the `Canonical::Material` polymorphic join model. Craftable weapons may be associated to the `Canonical::Material` model via the polymorphic `craftable` association. The material itself, regardless of class, will be the `source_material` on the `Canonical::Material` model.

## Tempering Materials

In general, weapons can be improved, or tempered, at a forge or anvil, if the player has the right materials and perks. (Unenchanted weapons may be improved somewhat regardless of perks, which double the increase in base damage from improving a weapon; enchanted weapons cannot be improved without the [Arcane Blacksmith](https://skyrim.fandom.com/wiki/Arcane_Blacksmith#:~:text=Arcane%20Blacksmith%20is%20a%20perk,and%20the%20Steel%20Smithing%20perk.) perk.) Tempering materials are nearly always `Canonical::RawMaterial`s, and all but one weapon can be improved with only one material. The exception is [Miraak's Sword](https://elderscrolls.fandom.com/wiki/Miraak's_Sword), which requires both an ebony ingot and a Daedra heart. This is also the only model to use a `Canonical::Ingredient` - or indeed, any class but `Canonical::RawMaterial` - for tempering.

Like crafting materials, tempering materials are associated using the `Canonical::Material` model. In this case, the weapon should be associated as the `temperable`, not the `craftable`. Note that `Canonical::Material`s must have one, and only one, of these associations defined.
