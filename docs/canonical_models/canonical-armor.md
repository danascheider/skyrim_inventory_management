# Canonical::Armor

The `Canonical::Armor` model represents a piece of armour in Skyrim. Like `Canonical::ClothingItem`s, `Canonical::Armor` models can have one of five `body_slot`s: "head", "body", "hands", "feet", "hair", or "shield".

## Enchantments

Armour pieces can be enchanted with enchantments via the `EnchantablesEnchantment` join model. Each piece of armour can have multiple enchantments associated. In-game items corresponding to canonical armour items with `enchantable` set to `true` may have new enchantments added by the user as well. (In addition to enchantments, the `magical_effects` field enables users to specify miscellaneous magical powers the armour may have.)

## Crafting Materials

Standard, non-enchanted armour items may typically be crafted at a forge or anvil (given the right materials and perks). The required materials to craft each item may be `Canonical::RawMaterial` models but may also be `Canonical::Ingredient`s. These associations are made using the `Canonical::Material` polymorphic join model. Craftable armour pieces may be associated to the `Canonical::Material` model via the polymorphic `craftable` association. The material itself, regardless of class, will be the `source_material` on the `Canonical::Material` model.

## Tempering Materials

In general, armour pieces can be improved, or tempered, at a forge or anvil, if the player has the right materials and perks. (Unenchanted armour pieces may be improved somewhat regardless of perks, which double the increase in base armour rating from improving a piece of armour; enchanted armour pieces cannot be improved without the [Arcane Blacksmith](https://skyrim.fandom.com/wiki/Arcane_Blacksmith#:~:text=Arcane%20Blacksmith%20is%20a%20perk,and%20the%20Steel%20Smithing%20perk.) perk.) Tempering materials are always `Canonical::RawMaterial`s. Armour items only need a single material to improve, with the single exception of the [Gloves of the Pugilist](https://elderscrolls.fandom.com/wiki/Gloves_of_the_Pugilist_(Skyrim)), which require both leather and leather strips.

Like crafting materials, tempering materials are associated using the `Canonical::Material` model. In this case, the piece of armour should be associated as the `temperable`, not the `craftable`. Note that `Canonical::Material`s must have one, and only one, of these associations defined.
